// TItanium-v2/load-balancer/main.go (최종 완성본)

package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"sync"
	"time"
)

// --- 통계 데이터 구조체 ---
type StatsCollector struct {
	mu                sync.RWMutex
	requests          []time.Time // RPS 계산을 위해 요청 시간 기록
	totalRequests     int64
	successCount      int64
	totalResponseTime time.Duration
}
type requestMetrics map[string]interface{}

var stats = &StatsCollector{}

// --- 통계 측정 미들웨어 ---
func statsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		startTime := time.Now()
		resWrapper := &responseWriterInterceptor{ResponseWriter: w, statusCode: http.StatusOK}
		next.ServeHTTP(resWrapper, r)
		duration := time.Since(startTime)

		stats.mu.Lock()
		stats.totalRequests++
		stats.requests = append(stats.requests, time.Now())
		if resWrapper.statusCode >= 200 && resWrapper.statusCode < 400 {
			stats.successCount++
		}
		stats.totalResponseTime += duration
		stats.mu.Unlock()
	})
}

// ... responseWriterInterceptor, getEnv, newProxy는 이전과 동일 ...
type responseWriterInterceptor struct {
	http.ResponseWriter
	statusCode int
}

func (i *responseWriterInterceptor) WriteHeader(statusCode int) {
	i.statusCode = statusCode
	i.ResponseWriter.WriteHeader(statusCode)
}
func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
func newProxy(target *url.URL) *httputil.ReverseProxy {
	return httputil.NewSingleHostReverseProxy(target)
}

// --- 개별 서비스 통계 수집 함수 ---
func fetchServiceStats(client *http.Client, serviceURL string) requestMetrics {
	resp, err := client.Get(serviceURL + "/stats")
	if err != nil {
		log.Printf("Error fetching stats from %s: %v", serviceURL, err)
		return requestMetrics{"service_status": "offline"}
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return requestMetrics{"service_status": "offline", "error": "failed to read body"}
	}
	var data requestMetrics
	if err := json.Unmarshal(body, &data); err != nil {
		return requestMetrics{"service_status": "offline", "error": "invalid json response"}
	}
	// [수정] 응답이 {"service_name": {...}} 형태이므로 내부 객체를 꺼내서 반환
	for _, value := range data {
		if v, ok := value.(map[string]interface{}); ok {
			return v
		}
	}
	return data
}

func main() {
	// --- 서비스 URL 설정 ---
	apiGatewayURL, _ := url.Parse(getEnv("API_GATEWAY_URL", "http://local-api-gateway-service:8000"))
	dashboardUIURL, _ := url.Parse(getEnv("DASHBOARD_UI_URL", "http://local-dashboard-ui-service:80"))
	authServiceURL := getEnv("AUTH_SERVICE_URL", "http://local-auth-service:8002")
	blogServiceURL := getEnv("BLOG_SERVICE_URL", "http://local-blog-service:8005")
	userServiceURL := getEnv("USER_SERVICE_URL", "http://local-user-service:8001")

	port := getEnv("LB_PORT", "7100")
	mux := http.NewServeMux()
	apiProxy := newProxy(apiGatewayURL)
	uiProxy := newProxy(dashboardUIURL)

	// --- [핵심] /stats 핸들러 최종 수정 ---
	mux.HandleFunc("/stats", func(w http.ResponseWriter, r *http.Request) {
		stats.mu.Lock()
		// RPS 계산: 최근 10초간의 요청 수를 10으로 나눔
		now := time.Now()
		tenSecondsAgo := now.Add(-10 * time.Second)
		var recentRequests int
		var newRequests []time.Time
		for _, t := range stats.requests {
			if t.After(tenSecondsAgo) {
				recentRequests++
				newRequests = append(newRequests, t)
			}
		}
		stats.requests = newRequests // 오래된 요청 기록은 삭제
		rps := float64(recentRequests) / 10.0

		// 나머지 통계 계산
		var avgResponseTimeMs float64
		if stats.totalRequests > 0 {
			avgResponseTimeMs = float64(stats.totalResponseTime.Milliseconds()) / float64(stats.totalRequests)
		}
		var successRate float64
		if stats.totalRequests > 0 {
			successRate = (float64(stats.successCount) / float64(stats.totalRequests)) * 100
		}

		combinedStats := requestMetrics{
			"load-balancer": requestMetrics{
				"total_requests": stats.totalRequests, "success_rate": successRate,
				"avg_response_time_ms": avgResponseTimeMs, "requests_per_second": rps, "status": "healthy",
			},
		}
		stats.mu.Unlock()

		// --- [수정] 모든 서비스의 통계를 가져오도록 확장 ---
		var wg sync.WaitGroup
		client := &http.Client{Timeout: 2 * time.Second}
		serviceUrls := map[string]string{
			"api-gateway": apiGatewayURL.String(), "user_service": userServiceURL,
			"auth": authServiceURL, "blog_service": blogServiceURL,
		}
		resultsChan := make(chan struct {
			key  string
			data requestMetrics
		}, len(serviceUrls))

		for key, url := range serviceUrls {
			wg.Add(1)
			go func(key, url string) {
				defer wg.Done()
				serviceStats := fetchServiceStats(client, url)
				resultsChan <- struct {
					key  string
					data requestMetrics
				}{key, serviceStats}
			}(key, url)
		}
		wg.Wait()
		close(resultsChan)

		for result := range resultsChan {
			// user_service의 DB, Cache 정보를 최상위로 올림
			if stats, ok := result.data["user_service"].(map[string]interface{}); ok {
				if db, dbOk := stats["database"]; dbOk {
					combinedStats["database"] = db
				}
				if cache, cacheOk := stats["cache"]; cacheOk {
					combinedStats["cache"] = cache
				}
				combinedStats["user_service"] = stats
			} else {
				combinedStats[result.key] = result.data
			}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(combinedStats)
	})

	// --- 라우팅 등록 순서 수정 ---
	mux.HandleFunc("/lb-health", func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(http.StatusOK) })
	mux.Handle("/api/", statsMiddleware(apiProxy))
	mux.Handle("/", statsMiddleware(uiProxy)) // 모든 요청을 통계 미들웨어로 감쌈

	log.Printf("Go Load Balancer (with Stats Aggregation) started on :%s", port)
	if err := http.ListenAndServe(":"+port, mux); err != nil {
		log.Fatal(err)
	}
}
