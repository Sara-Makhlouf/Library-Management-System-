import React, { useState, useRef, useEffect } from "react";
import {
  Sparkles, AlertTriangle, Send, Wand2,
  BookMarked, Loader2, RefreshCw, TrendingUp,
  TrendingDown, Minus, Radio, Brain
} from "lucide-react";

const monthly = [
  { month: "Jan", borrows: 120, returns: 100, overdue: 18 },
  { month: "Feb", borrows: 210, returns: 150, overdue: 22 },
  { month: "Mar", borrows: 180, returns: 170, overdue: 20 },
  { month: "Apr", borrows: 250, returns: 200, overdue: 25 },
  { month: "May", borrows: 300, returns: 280, overdue: 41 },
  { month: "Jun", borrows: 280, returns: 210, overdue: 32 },
];

const categories = [
  { name: "Science", value: 400 },
  { name: "Novels", value: 300 },
  { name: "History", value: 200 },
  { name: "Tech", value: 278 },
];

const members = [
  { id: 1, name: "Lina H.", recentCategory: "Science", borrows: 14 },
  { id: 2, name: "Omar K.", recentCategory: "Tech", borrows: 9 },
  { id: 3, name: "Sara M.", recentCategory: "Novels", borrows: 21 },
  { id: 4, name: "Yousef A.", recentCategory: "History", borrows: 7 },
  { id: 5, name: "Maya T.", recentCategory: "Science", borrows: 17 },
];

const DATA_CONTEXT = `
Monthly borrows/returns/overdue (last 6 months): ${JSON.stringify(monthly)}
Category popularity (item counts): ${JSON.stringify(categories)}
Sample member borrowing activity: ${JSON.stringify(members)}
`;

async function askClaude(prompt, { json = false } = {}) {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "claude-sonnet-4-6",
      max_tokens: 1100,
      messages: [{ role: "user", content: prompt }],
    }),
  });
  if (!res.ok) throw new Error("API request failed: " + res.status);
  const data = await res.json();
  const text = (data.content || [])
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("\n")
    .trim();
  if (json) {
    const cleaned = text.replace(/```json|```/g, "").trim();
    return JSON.parse(cleaned);
  }
  return text;
}

export default function LibraryAICommandCenter() {
  const [isNarrow, setIsNarrow] = useState(
    typeof window !== "undefined" ? window.innerWidth < 880 : false
  );
  useEffect(() => {
    const onResize = () => setIsNarrow(window.innerWidth < 880);
    window.addEventListener("resize", onResize);
    return () => window.removeEventListener("resize", onResize);
  }, []);

  const [insights, setInsights] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [lastRun, setLastRun] = useState(null);

  const [chatMessages, setChatMessages] = useState([
    { role: "assistant", text: "I'm watching circulation, overdue patterns, and category demand. Ask me anything about what's happening in the library right now." },
  ]);
  const [chatInput, setChatInput] = useState("");
  const [chatLoading, setChatLoading] = useState(false);
  const chatEndRef = useRef(null);

  const runFullAnalysis = async () => {
    setLoading(true);
    setError(null);
    try {
      const prompt = `You are the reasoning engine behind a library's AI command center. Based ONLY on this data, respond with STRICT JSON only (no markdown fences, no preamble), matching exactly this shape:

{
  "headline": "one confident sentence stating the single most important thing happening right now, with a real number",
  "confidence": number from 60 to 99,
  "narrative": "2-3 sentences of supporting analysis, specific and grounded in the numbers",
  "forecast": {
    "topCategory": "category name expected to see highest demand next month",
    "direction": "up|down|flat",
    "expectedChangePercent": number,
    "reasoning": "1 sentence reasoning grounded in the category data",
    "confidence": number from 60 to 99
  },
  "anomalies": [
    { "severity": "low|medium|high", "title": "short title", "detail": "1 sentence explanation citing numbers", "confidence": number from 60 to 99 }
  ],
  "recommendations": [
    { "memberName": "name from the data", "suggestedCategory": "category", "reasoning": "short reasoning grounded in their activity" }
  ]
}

Data:
${DATA_CONTEXT}

Rules: anomalies should only flag things that are genuinely notable (e.g. a real spike or drop). Empty array if nothing stands out. Max 3 recommendations. Respond with JSON only, no other text.`;

      const result = await askClaude(prompt, { json: true });
      setInsights(result);
      setLastRun(new Date());
    } catch (err) {
      console.error(err);
      setError("Analysis engine couldn't complete this pass.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    runFullAnalysis();
  }, []);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [chatMessages]);

  const sendChat = async () => {
    const question = chatInput.trim();
    if (!question || chatLoading) return;
    setChatInput("");
    setChatMessages((m) => [...m, { role: "user", text: question }]);
    setChatLoading(true);
    try {
      const prompt = `You are the library's AI command center assistant. Answer using ONLY the data below. Be concise (2-4 sentences), specific, cite real numbers. If the data can't answer it, say so plainly.

Data:
${DATA_CONTEXT}

Question: ${question}`;
      const answer = await askClaude(prompt);
      setChatMessages((m) => [...m, { role: "assistant", text: answer }]);
    } catch {
      setChatMessages((m) => [...m, { role: "assistant", text: "Couldn't reach the reasoning engine just now — try again in a moment." }]);
    } finally {
      setChatLoading(false);
    }
  };

  return (
    <div style={styles.page}>
      <GlobalStyle />
      <TopBar loading={loading} lastRun={lastRun} onRefresh={runFullAnalysis} />

      <HeadlineCard insights={insights} loading={loading} error={error} onRetry={runFullAnalysis} />

      <div style={{
        display: "grid",
        gridTemplateColumns: isNarrow ? "1fr" : "1fr 1fr 1fr",
        gap: 20,
        marginTop: 20,
      }}>
        <ForecastCard insights={insights} loading={loading} />
        <AnomalyCard insights={insights} loading={loading} />
        <RecommendationCard insights={insights} loading={loading} />
      </div>

      <ChatConsole
        messages={chatMessages}
        input={chatInput}
        setInput={setChatInput}
        loading={chatLoading}
        onSend={sendChat}
        endRef={chatEndRef}
      />
    </div>
  );
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
      input:focus, button:focus-visible { outline: 2px solid #c9a84c; outline-offset: 2px; }
      @media (prefers-reduced-motion: reduce) {
        .spin, .pulse-dot, .rise-in { animation: none !important; }
      }
    `}</style>
  );
}


function TopBar({ loading, lastRun, onRefresh }) {
  return (
    <div style={styles.topBar}>
      <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
        <div style={styles.logoMark}>
          <Brain size={18} />
        </div>
        <div>
          <div style={styles.logoTitle}>Athenaeum</div>
          <div style={styles.logoSub}>Library reasoning engine</div>
        </div>
      </div>

      <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
        <StatusPill loading={loading} lastRun={lastRun} />
        <button onClick={onRefresh} disabled={loading} style={styles.refreshBtn}>
          <RefreshCw size={14} className={loading ? "spin" : ""} />
          Re-run analysis
        </button>
      </div>
    </div>
  );
}

function StatusPill({ loading, lastRun }) {
  return (
    <div style={styles.statusPill}>
      <span
        className={loading ? "pulse-dot" : ""}
        style={{
          width: 7, height: 7, borderRadius: 999,
          background: loading ? "#c9a84c" : "#7dd3c0",
          boxShadow: loading ? "0 0 8px #c9a84c" : "0 0 8px #7dd3c0",
        }}
      />
      <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 11.5, color: "rgba(232,227,216,0.55)" }}>
        {loading ? "ANALYZING" : lastRun ? `LIVE · UPDATED ${formatTime(lastRun)}` : "STANDBY"}
      </span>
    </div>
  );
}

function formatTime(d) {
  return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

function HeadlineCard({ insights, loading, error, onRetry }) {
  return (
    <div style={styles.headlineCard}>
      <div style={styles.headlineGlow} />
      <div style={{ position: "relative", zIndex: 1 }}>
        <div style={styles.eyebrow}>
          <Sparkles size={13} /> AI READING — THIS PERIOD
        </div>

        {loading && (
          <div className="rise-in">
            <SkeletonBlock width="78%" height={32} />
            <div style={{ height: 14 }} />
            <SkeletonBlock width="95%" height={14} />
            <SkeletonBlock width="60%" height={14} />
          </div>
        )}

        {error && !loading && (
          <div style={{ color: "rgba(232,227,216,0.6)" }}>
            {error}{" "}
            <button onClick={onRetry} style={styles.linkBtn}>
              <RefreshCw size={12} /> Retry
            </button>
          </div>
        )}

        {!loading && !error && insights && (
          <div className="rise-in">
            <div style={styles.headline}>{insights.headline}</div>
            <p style={styles.narrative}>{insights.narrative}</p>
            <ConfidenceBar value={insights.confidence} label="Confidence in this read" />
          </div>
        )}
      </div>
    </div>
  );
}

function ConfidenceBar({ value, label }) {
  if (value == null) return null;
  return (
    <div style={{ marginTop: 18, maxWidth: 320 }}>
      <div style={{
        display: "flex", justifyContent: "space-between", marginBottom: 6,
        fontFamily: "'JetBrains Mono', monospace", fontSize: 10.5,
        color: "rgba(232,227,216,0.45)", letterSpacing: 0.4,
      }}>
        <span>{label}</span>
        <span>{value}%</span>
      </div>
      <div style={{ height: 4, borderRadius: 999, background: "rgba(255,255,255,0.07)", overflow: "hidden" }}>
        <div style={{
          height: "100%", width: `${value}%`, borderRadius: 999,
          background: "linear-gradient(90deg, #7dd3c0, #c9a84c)",
          transition: "width 0.6s ease",
        }} />
      </div>
    </div>
  );
}

function ForecastCard({ insights, loading }) {
  const f = insights?.forecast;
  const DirIcon = f?.direction === "down" ? TrendingDown : f?.direction === "flat" ? Minus : TrendingUp;
  return (
    <SystemCard
      icon={<DirIcon size={15} />}
      label="DEMAND FORECAST"
      accent="#3b82f6"
      loading={loading}
    >
      {f && (
        <>
          <div style={{ display: "flex", alignItems: "baseline", gap: 10, marginBottom: 10 }}>
            <span style={styles.cardBigValue}>{f.topCategory}</span>
            <span style={{
              fontFamily: "'JetBrains Mono', monospace", fontSize: 13, fontWeight: 600,
              color: f.direction === "down" ? "#ff6b5e" : "#7dd3c0",
            }}>
              {f.expectedChangePercent > 0 ? "+" : ""}{f.expectedChangePercent}%
            </span>
          </div>
          <p style={styles.cardBody}>{f.reasoning}</p>
          <ConfidenceBar value={f.confidence} label="Forecast confidence" />
        </>
      )}
    </SystemCard>
  );
}

function AnomalyCard({ insights, loading }) {
  const anomalies = insights?.anomalies || [];
  return (
    <SystemCard
      icon={<AlertTriangle size={15} />}
      label="ANOMALY DETECTION"
      accent="#ff6b5e"
      loading={loading}
    >
      {anomalies.length === 0 && (
        <p style={{ ...styles.cardBody, color: "#7dd3c0" }}>
          Signal is clean — nothing outside expected range.
        </p>
      )}
      {anomalies.map((a, i) => (
        <div key={i} style={{
          padding: "10px 0",
          borderTop: i > 0 ? "1px solid rgba(255,255,255,0.06)" : "none",
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 4 }}>
            <SeverityDot severity={a.severity} />
            <span style={{ fontSize: 13.5, fontWeight: 600 }}>{a.title}</span>
          </div>
          <p style={{ ...styles.cardBody, marginLeft: 16 }}>{a.detail}</p>
        </div>
      ))}
    </SystemCard>
  );
}

function SeverityDot({ severity }) {
  const color = severity === "high" ? "#ff6b5e" : severity === "medium" ? "#e8b54c" : "#888";
  return <span style={{ width: 7, height: 7, borderRadius: 999, background: color, flexShrink: 0 }} />;
}

function RecommendationCard({ insights, loading }) {
  const recs = insights?.recommendations || [];
  return (
    <SystemCard
      icon={<BookMarked size={15} />}
      label="MEMBER MATCHING"
      accent="#f472b6"
      loading={loading}
    >
      {recs.length === 0 && <p style={styles.cardBody}>No strong matches surfaced this period.</p>}
      {recs.map((r, i) => (
        <div key={i} style={{
          display: "flex", justifyContent: "space-between", alignItems: "center",
          padding: "9px 0",
          borderTop: i > 0 ? "1px solid rgba(255,255,255,0.06)" : "none",
        }}>
          <div>
            <div style={{ fontSize: 13.5, fontWeight: 600 }}>{r.memberName}</div>
            <div style={{ ...styles.cardBody, marginTop: 1 }}>{r.reasoning}</div>
          </div>
          <span style={styles.tag}>{r.suggestedCategory}</span>
        </div>
      ))}
    </SystemCard>
  );
}

function SystemCard({ icon, label, accent, loading, children }) {
  return (
    <div style={{ ...styles.systemCard, borderColor: `${accent}2e` }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 16 }}>
        <span style={{ color: accent, display: "flex" }}>{icon}</span>
        <span style={styles.cardLabel}>{label}</span>
      </div>
      {loading ? (
        <div>
          <SkeletonBlock width="85%" height={13} />
          <SkeletonBlock width="60%" height={13} />
          <SkeletonBlock width="70%" height={13} />
        </div>
      ) : (
        <div className="rise-in">{children}</div>
      )}
    </div>
  );
}

function SkeletonBlock({ width, height }) {
  return (
    <div style={{
      width, height, borderRadius: 6, marginBottom: 8,
      background: "linear-gradient(90deg, rgba(255,255,255,0.04), rgba(255,255,255,0.09), rgba(255,255,255,0.04))",
    }} />
  );
}

function ChatConsole({ messages, input, setInput, loading, onSend, endRef }) {
  return (
    <div style={styles.chatShell}>
      <div style={styles.chatHeader}>
        <Wand2 size={14} style={{ color: "#c9a84c" }} />
        <span style={{ fontWeight: 600, fontSize: 13.5 }}>Ask the reasoning engine</span>
        <Radio size={11} style={{ color: "#7dd3c0", marginLeft: "auto" }} />
      </div>

      <div style={styles.chatBody}>
        {messages.map((m, i) => (
          <div key={i} style={{
            alignSelf: m.role === "user" ? "flex-end" : "flex-start",
            maxWidth: "78%",
            padding: "9px 13px",
            borderRadius: 12,
            fontSize: 13.5,
            lineHeight: 1.5,
            background: m.role === "user" ? "#c9a84c" : "rgba(255,255,255,0.05)",
            color: m.role === "user" ? "#0a0a0f" : "rgba(232,227,216,0.9)",
            border: m.role === "user" ? "none" : "1px solid rgba(255,255,255,0.06)",
          }}>
            {m.text}
          </div>
        ))}
        {loading && (
          <div style={{ alignSelf: "flex-start", display: "flex", alignItems: "center", gap: 6, color: "rgba(232,227,216,0.4)", fontSize: 12.5 }}>
            <Loader2 size={12} className="spin" /> reasoning…
          </div>
        )}
        <div ref={endRef} />
      </div>

      <div style={styles.chatInputRow}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && onSend()}
          placeholder="Ask about overdue trends, categories, members…"
          style={styles.chatInput}
        />
        <button
          onClick={onSend}
          disabled={loading || !input.trim()}
          style={{
            ...styles.sendBtn,
            opacity: loading || !input.trim() ? 0.4 : 1,
            cursor: loading || !input.trim() ? "not-allowed" : "pointer",
          }}
        >
          <Send size={14} />
        </button>
      </div>
    </div>
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    background: "radial-gradient(circle at 20% 0%, #14131c 0%, #0a0a0f 55%)",
    color: "#e8e3d8",
    fontFamily: "'Inter', sans-serif",
    marginLeft:"-16px",
    padding: "28px 28px 80px",
  },
  topBar: {
    display: "flex", justifyContent: "space-between", alignItems: "center",
    flexWrap: "wrap", gap: 16, marginBottom: 24,
  },
  logoMark: {
    width: 36, height: 36, borderRadius: 10,
    background: "linear-gradient(135deg, #c9a84c, #7dd3c0)",
    display: "flex", alignItems: "center", justifyContent: "center", color: "#0a0a0f",
  },
  logoTitle: { fontFamily: "'Fraunces', serif", fontSize: 19, fontWeight: 600, lineHeight: 1.1 },
  logoSub: { fontSize: 11.5, color: "rgba(232,227,216,0.4)", marginTop: 2 },
  statusPill: {
    display: "flex", alignItems: "center", gap: 8,
    padding: "6px 12px", borderRadius: 999,
    background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.07)",
  },
  refreshBtn: {
    display: "flex", alignItems: "center", gap: 7,
    background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)",
    color: "#e8e3d8", padding: "8px 14px", borderRadius: 10, fontSize: 12.5, fontWeight: 600,
    cursor: "pointer",
  },
  headlineCard: {
    position: "relative", overflow: "hidden",
    padding: "30px 32px", borderRadius: 24,
    background: "#13121a",
    border: "1px solid rgba(201,168,76,0.18)",
  },
  headlineGlow: {
    position: "absolute", top: -80, right: -80, width: 280, height: 280, borderRadius: "50%",
    background: "radial-gradient(circle, rgba(201,168,76,0.16), transparent 70%)",
    pointerEvents: "none",
  },
  eyebrow: {
    display: "flex", alignItems: "center", gap: 7,
    fontFamily: "'JetBrains Mono', monospace", fontSize: 11, letterSpacing: 0.8,
    color: "#c9a84c", marginBottom: 16, fontWeight: 500,
  },
  headline: {
    fontFamily: "'Fraunces', serif", fontSize: "clamp(22px, 3vw, 32px)",
    fontWeight: 600, lineHeight: 1.25, maxWidth: 720, marginBottom: 14,
  },
  narrative: {
    fontSize: 14.5, lineHeight: 1.65, color: "rgba(232,227,216,0.65)",
    maxWidth: 620, margin: 0,
  },
  systemCard: {
    padding: "22px 22px", borderRadius: 18,
    background: "#13121a", border: "1px solid rgba(255,255,255,0.06)",
  },
  cardLabel: {
    fontFamily: "'JetBrains Mono', monospace", fontSize: 11, letterSpacing: 0.6,
    color: "rgba(232,227,216,0.5)", fontWeight: 500,
  },
  cardBigValue: { fontFamily: "'Fraunces', serif", fontSize: 21, fontWeight: 600 },
  cardBody: { fontSize: 12.5, lineHeight: 1.55, color: "rgba(232,227,216,0.55)", margin: 0 },
  tag: {
    fontFamily: "'JetBrains Mono', monospace", fontSize: 10.5, fontWeight: 600,
    color: "#f472b6", background: "rgba(244,114,182,0.1)",
    padding: "4px 9px", borderRadius: 999, whiteSpace: "nowrap", marginLeft: 10,
  },
  linkBtn: {
    display: "inline-flex", alignItems: "center", gap: 4, background: "none", border: "none",
    color: "#c9a84c", cursor: "pointer", fontSize: 13.5, padding: 0, fontWeight: 600,
  },
  chatShell: {
    marginTop: 20, borderRadius: 20, background: "#13121a",
    border: "1px solid rgba(255,255,255,0.07)", overflow: "hidden",
    display: "flex", flexDirection: "column", height: 360,
  },
  chatHeader: {
    display: "flex", alignItems: "center", gap: 9,
    padding: "14px 18px", borderBottom: "1px solid rgba(255,255,255,0.06)",
  },
  chatBody: {
    flex: 1, overflowY: "auto", padding: 18,
    display: "flex", flexDirection: "column", gap: 10,
  },
  chatInputRow: {
    display: "flex", gap: 10, padding: 14,
    borderTop: "1px solid rgba(255,255,255,0.06)",
  },
  chatInput: {
    flex: 1, background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)",
    borderRadius: 10, padding: "10px 14px", color: "#e8e3d8", fontSize: 13.5, outline: "none",
    fontFamily: "'Inter', sans-serif",
  },
  sendBtn: {
    width: 40, height: 40, borderRadius: 10, border: "none", flexShrink: 0,
    background: "#c9a84c", color: "#0a0a0f",
    display: "flex", alignItems: "center", justifyContent: "center",
  },
};