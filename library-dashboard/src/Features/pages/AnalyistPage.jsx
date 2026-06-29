import React, { useEffect, useMemo, useState } from "react";

import { useDispatch, useSelector } from "react-redux";

import {BookOpen, TrendingUp, TrendingDown, Minus, RefreshCw,Receipt, BookMarked, Brain, AlertCircle, Crown} from "lucide-react";

import {getDashboardStats, getWeeklySales,getTopSellingBooks,getWeeklyBorrows} from "../../Core/Redux/Thunks/DashboardThunk";

import { getTotalPaidOrder, getTotalBorrows } from "../../Core/Redux/Thunks/AnalayistThunk";

import { useAIChat } from "../Utils/useInsight";
import AIChatCard from "../Utils/insightCard";


function normalizeSeries(raw) {
  if (!raw) return [];
  if (Array.isArray(raw)) {
    return raw.map((item, i) => {
      if (typeof item === "number") return { label: `#${i + 1}`, value: item };
      const label =
        item.day ?? item.date ?? item.label ?? item.week ?? item.name ?? `#${i + 1}`;
      const value =
        item.count ?? item.value ?? item.total ?? item.sales ?? item.borrows ?? 0;
      return { label: String(label), value: Number(value) || 0 };
    });
  }
  if (typeof raw === "object") {
    if (Array.isArray(raw.labels) && Array.isArray(raw.values)) {
      return raw.labels.map((label, i) => ({ label: String(label), value: Number(raw.values[i]) || 0 }));
    }
    return Object.entries(raw).map(([label, value]) => ({
      label,
      value: Number(value) || 0,
    }));
  }
  return [];
}

function extractNumber(payload, keys = []) {
  if (payload == null) return null;
  if (typeof payload === "number") return payload;
  let data = payload.data ?? payload;
  if (Array.isArray(data)) data = data[0] ?? {};
  for (const k of keys) {
    if (data && data[k] !== undefined && data[k] !== null) {
      const raw = data[k];
      const n = typeof raw === "string" ? parseFloat(raw.replace(/[^\d.-]/g, "")) : raw;
      if (!Number.isNaN(n)) return n;
    }
  }
  return null;
}

function extractString(payload, keys = []) {
  if (payload == null) return null;
  let data = payload.data ?? payload;
  if (Array.isArray(data)) data = data[0] ?? {};
  for (const k of keys) {
    if (data && data[k] !== undefined && data[k] !== null) return data[k];
  }
  return null;
}

function extractBorrowsBreakdown(payload) {
  const data = payload?.data ?? payload;
  if (!data || typeof data !== "object") return null;
  const returned = Number(data.returned?.count) || 0;
  const active = Number(data.active?.count) || 0;
  const expired = Number(data.expired?.count) || 0;
  return { returned, active, expired, total: returned + active + expired };
}


export default function DashboardCommandCenter() {
  const dispatch = useDispatch();

  const [isNarrow, setIsNarrow] = useState(
    typeof window !== "undefined" ? window.innerWidth < 880 : false
  );
  useEffect(() => {
    const onResize = () => setIsNarrow(window.innerWidth < 880);
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  const {
    
    weeklySales,
    weeklyBorrows,
    topSellingBooks,
    loading: dashboardLoading,
    error: dashboardError,
  } = useSelector((s) => s.dashboard) || {};

  const {
    totalPaidOrder,
    totalBorrows,
    loading: analystLoading,
    error: analystError,
  } = useSelector((s) => s.Analyise) || {};

  const loading = dashboardLoading || analystLoading;
  const error = dashboardError || analystError;

  const loadAll = () => {
    dispatch(getDashboardStats());
    dispatch(getWeeklySales());
    dispatch(getWeeklyBorrows());
    dispatch(getTopSellingBooks());
    dispatch(getTotalPaidOrder());
    dispatch(getTotalBorrows());
  };

  useEffect(() => {
    loadAll();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const salesSeries = useMemo(() => normalizeSeries(weeklySales), [weeklySales]);
  const borrowsSeries = useMemo(() => normalizeSeries(weeklyBorrows), [weeklyBorrows]);

  const totalOrdersCount = extractNumber(totalPaidOrder, [
    "total_paid_orders",
    "total_orders",
    "count",
    "total",
  ]);
  const reportDate = extractString(totalPaidOrder, ["report_date", "date"]);
  const borrowsBreakdown = useMemo(() => extractBorrowsBreakdown(totalBorrows), [totalBorrows]);

  const salesTrend = trendOf(salesSeries);
  const borrowsTrend = trendOf(borrowsSeries);

  // --- AI Chat ---
  const { messages, loading: aiLoading, error: aiError, sendMessage, resetChat } = useAIChat();

  const handleSendMessage = (text) => {
    sendMessage(text, {
      salesSeries,
      borrowsSeries,
      topSellingBooks,
      totalOrdersCount,
      borrowsBreakdown,
    });
  };

  return (
    <div style={styles.page}>
      <GlobalStyle />
      <TopBar loading={loading} reportDate={reportDate} onRefresh={loadAll} />

      {error && <ErrorBanner message={String(error)} onRetry={loadAll} />}

      <div
        style={{
          display: "grid",
          gridTemplateColumns: isNarrow ? "1fr" : "repeat(3, 1fr)",
          gap: 16,
          marginBottom: 20,
        }}
      >
        <StatCard
          icon={<Receipt size={15} />}
          accent="#7dd3c0"
          label="PAID ORDERS"
          value={totalOrdersCount ?? "—"}
          loading={loading}
        />
        <StatCard
          icon={<BookMarked size={15} />}
          accent="#3b82f6"
          label="TOTAL BORROWS"
          value={borrowsBreakdown?.total ?? "—"}
          loading={loading}
          subtext={
            borrowsBreakdown
              ? `${borrowsBreakdown.returned} returned · ${borrowsBreakdown.active} active · ${borrowsBreakdown.expired} expired`
              : null
          }
        />
        <StatCard
          icon={<BookOpen size={15} />}
          accent="#f472b6"
          label="TRACKED TITLES"
          value={topSellingBooks?.length ?? "—"}
          loading={loading}
        />
      </div>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: isNarrow ? "1fr" : "1fr 1fr",
          gap: 20,
          marginBottom: 20,
        }}
      >
        <SeriesCard
          title="WEEKLY SALES"
          icon={<TrendingUp size={15} />}
          accent="#c9a84c"
          series={salesSeries}
          trend={salesTrend}
          loading={loading}
          emptyText="No sales activity recorded yet."
        />
        <SeriesCard
          title="WEEKLY BORROWS"
          icon={<BookMarked size={15} />}
          accent="#3b82f6"
          series={borrowsSeries}
          trend={borrowsTrend}
          loading={loading}
          emptyText="No borrow activity recorded yet."
        />
      </div>

      <TopSellingCard books={topSellingBooks} loading={loading} />

      <div style={{ marginTop: 20 }}>
        <AIChatCard
          messages={messages}
          loading={aiLoading}
          error={aiError}
          onSend={handleSendMessage}
          onReset={resetChat}
        />
      </div>
    </div>
  );
}

function trendOf(series) {
  if (!series || series.length < 2) return null;
  const first = series[0].value;
  const last = series[series.length - 1].value;
  if (last > first) return "up";
  if (last < first) return "down";
  return "flat";
}


function GlobalStyle() {
  return (
    <style>{`
      @import url('https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400..700&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');
      @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
      @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.35; } }
      @keyframes rise { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
      .spin { animation: spin 1.1s linear infinite; }
      .pulse-dot { animation: pulse 1.8s ease-in-out infinite; }
      .rise-in { animation: rise 0.45s ease both; }
      ::selection { background: rgba(201,168,76,0.35); }
      * { box-sizing: border-box; }
      button:focus-visible { outline: 2px solid #c9a84c; outline-offset: 2px; }
      @media (prefers-reduced-motion: reduce) {
        .spin, .pulse-dot, .rise-in { animation: none !important; }
      }
    `}</style>
  );
}

function TopBar({ loading, reportDate, onRefresh }) {
  return (
    <div style={styles.topBar}>
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <div style={styles.logoMark}>
          <Brain size={18} />
        </div>
        <div>
          <div style={styles.logoTitle}>Athenaeum</div>
          <div style={styles.logoSub}>Operations dashboard</div>
        </div>
      </div>

      <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
        <StatusPill loading={loading} reportDate={reportDate} />
        <button onClick={onRefresh} disabled={loading} style={styles.refreshBtn}>
          <RefreshCw size={14} className={loading ? "spin" : ""} />
          Refresh
        </button>
      </div>
    </div>
  );
}

function StatusPill({ loading, reportDate }) {
  return (
    <div style={styles.statusPill}>
      <span
        className={loading ? "pulse-dot" : ""}
        style={{
          width: 7,
          height: 7,
          borderRadius: 999,
          background: loading ? "#c9a84c" : "#7dd3c0",
          boxShadow: loading ? "0 0 8px #c9a84c" : "0 0 8px #7dd3c0",
        }}
      />
      <span
        style={{
          fontFamily: "'JetBrains Mono', monospace",
          fontSize: 11.5,
          color: "rgba(232,227,216,0.55)",
        }}
      >
        {loading ? "SYNCING" : reportDate ? `LIVE · ${reportDate}` : "LIVE"}
      </span>
    </div>
  );
}

function ErrorBanner({ message, onRetry }) {
  return (
    <div style={styles.errorBanner}>
      <AlertCircle size={15} style={{ color: "#ff6b5e", flexShrink: 0 }} />
      <span style={{ fontSize: 13, color: "rgba(232,227,216,0.75)", flex: 1 }}>
        {message}
      </span>
      <button onClick={onRetry} style={styles.linkBtn}>
        <RefreshCw size={12} /> Retry
      </button>
    </div>
  );
}

function StatCard({ icon, accent, label, value, loading, subtext }) {
  return (
    <div style={{ ...styles.statCard, borderColor: `${accent}2e` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 12 }}>
        <span style={{ color: accent, display: "flex" }}>{icon}</span>
        <span style={styles.cardLabel}>{label}</span>
      </div>
      {loading ? (
        <SkeletonBlock width="60%" height={26} />
      ) : (
        <div className="rise-in">
          <div style={styles.statValue}>{value}</div>
          {subtext && (
            <div
              style={{
                fontFamily: "'JetBrains Mono', monospace",
                fontSize: 10.5,
                color: "rgba(232,227,216,0.4)",
                marginTop: 6,
              }}
            >
              {subtext}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function SeriesCard({ title, icon, accent, series, trend, loading, emptyText }) {
  const max = Math.max(1, ...series.map((s) => s.value));
  const DirIcon = trend === "down" ? TrendingDown : trend === "flat" ? Minus : TrendingUp;

  return (
    <div style={{ ...styles.systemCard, borderColor: `${accent}2e` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 18 }}>
        <span style={{ color: accent, display: "flex" }}>{icon}</span>
        <span style={styles.cardLabel}>{title}</span>
        {trend && (
          <span style={{ marginLeft: "auto", color: trend === "down" ? "#ff6b5e" : "#7dd3c0", display: "flex" }}>
            <DirIcon size={14} />
          </span>
        )}
      </div>

      {loading ? (
        <div>
          <SkeletonBlock width="100%" height={120} />
        </div>
      ) : series.length === 0 ? (
        <p style={styles.cardBody}>{emptyText}</p>
      ) : (
        <div className="rise-in" style={{ display: "flex", alignItems: "flex-end", gap: 8, height: 140 }}>
          {series.map((point, i) => (
            <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
              <div
                title={`${point.label}: ${point.value}`}
                style={{
                  width: "100%",
                  maxWidth: 36,
                  height: Math.max(4, (point.value / max) * 100),
                  borderRadius: "6px 6px 2px 2px",
                  background: `linear-gradient(180deg, ${accent}, ${accent}55)`,
                }}
              />
              <span
                style={{
                  fontFamily: "'JetBrains Mono', monospace",
                  fontSize: 10,
                  color: "rgba(232,227,216,0.4)",
                  whiteSpace: "nowrap",
                }}
              >
                {point.label}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function TopSellingCard({ books, loading }) {
  const list = Array.isArray(books) ? books : [];
  return (
    <div style={{ ...styles.systemCard, marginTop: 20, borderColor: "rgba(244,114,182,0.18)" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 16 }}>
        <span style={{ color: "#f472b6", display: "flex" }}>
          <Crown size={15} />
        </span>
        <span style={styles.cardLabel}>TOP SELLING BOOKS</span>
      </div>

      {loading ? (
        <div>
          <SkeletonBlock width="90%" height={14} />
          <SkeletonBlock width="75%" height={14} />
          <SkeletonBlock width="80%" height={14} />
        </div>
      ) : list.length === 0 ? (
        <p style={styles.cardBody}>No sales data yet.</p>
      ) : (
        <div className="rise-in">
          {list.map((b, i) => (
            <div
              key={b.book_id ?? i}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 12,
                padding: "10px 0",
                borderTop: i > 0 ? "1px solid rgba(255,255,255,0.06)" : "none",
              }}
            >
              <span
                style={{
                  fontFamily: "'JetBrains Mono', monospace",
                  fontSize: 11,
                  color: "rgba(232,227,216,0.35)",
                  width: 20,
                  flexShrink: 0,
                }}
              >
                {String(i + 1).padStart(2, "0")}
              </span>
              <span
                style={{
                  fontSize: 13.5,
                  color: "rgba(232,227,216,0.9)",
                  flex: 1,
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                }}
              >
                {b.book_title}
              </span>
              {b.is_active === false && (
                <span style={{ ...styles.tag, color: "#888", background: "rgba(255,255,255,0.06)" }}>
                  inactive
                </span>
              )}
              <span style={styles.tag}>{b.units_sold} sold</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function SkeletonBlock({ width, height }) {
  return (
    <div
      style={{
        width,
        height,
        borderRadius: 6,
        marginBottom: 8,
        background:
          "linear-gradient(90deg, rgba(255,255,255,0.04), rgba(255,255,255,0.09), rgba(255,255,255,0.04))",
      }}
    />
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    background: "radial-gradient(circle at 20% 0%, #14131c 0%, #0a0a0f 55%)",
    color: "#e8e3d8",
    fontFamily: "'Inter', sans-serif",
    padding: "28px 28px 80px",
    marginLeft:"-16px",
  },
  topBar: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    flexWrap: "wrap",
    gap: 16,
    marginBottom: 24,
  },
  logoMark: {
    width: 36,
    height: 36,
    borderRadius: 10,
    background: "linear-gradient(135deg, #c9a84c, #7dd3c0)",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    color: "#0a0a0f",
  },
  logoTitle: { fontFamily: "'Fraunces', serif", fontSize: 19, fontWeight: 600, lineHeight: 1.1 },
  logoSub: { fontSize: 11.5, color: "rgba(232,227,216,0.4)", marginTop: 2 },
  statusPill: {
    display: "flex",
    alignItems: "center",
    gap: 8,
    padding: "6px 12px",
    borderRadius: 999,
    background: "rgba(255,255,255,0.04)",
    border: "1px solid rgba(255,255,255,0.07)",
  },
  refreshBtn: {
    display: "flex",
    alignItems: "center",
    gap: 7,
    background: "rgba(255,255,255,0.05)",
    border: "1px solid rgba(255,255,255,0.1)",
    color: "#e8e3d8",
    padding: "8px 14px",
    borderRadius: 10,
    fontSize: 12.5,
    fontWeight: 600,
    cursor: "pointer",
  },
  errorBanner: {
    display: "flex",
    alignItems: "center",
    gap: 10,
    padding: "12px 16px",
    borderRadius: 12,
    background: "rgba(255,107,94,0.08)",
    border: "1px solid rgba(255,107,94,0.25)",
    marginBottom: 20,
  },
  statCard: {
    padding: "18px 20px",
    borderRadius: 16,
    background: "#13121a",
    border: "1px solid rgba(255,255,255,0.06)",
  },
  statValue: {
    fontFamily: "'Fraunces', serif",
    fontSize: 24,
    fontWeight: 600,
  },
  systemCard: {
    padding: "22px 22px",
    borderRadius: 18,
    background: "#13121a",
    border: "1px solid rgba(255,255,255,0.06)",
  },
  cardLabel: {
    fontFamily: "'JetBrains Mono', monospace",
    fontSize: 11,
    letterSpacing: 0.6,
    color: "rgba(232,227,216,0.5)",
    fontWeight: 500,
  },
  cardBody: { fontSize: 12.5, lineHeight: 1.55, color: "rgba(232,227,216,0.55)", margin: 0 },
  tag: {
    fontFamily: "'JetBrains Mono', monospace",
    fontSize: 10.5,
    fontWeight: 600,
    color: "#f472b6",
    background: "rgba(244,114,182,0.1)",
    padding: "4px 9px",
    borderRadius: 999,
    whiteSpace: "nowrap",
    flexShrink: 0,
  },
  linkBtn: {
    display: "inline-flex",
    alignItems: "center",
    gap: 4,
    background: "none",
    border: "none",
    color: "#c9a84c",
    cursor: "pointer",
    fontSize: 13,
    padding: 0,
    fontWeight: 600,
  },
};