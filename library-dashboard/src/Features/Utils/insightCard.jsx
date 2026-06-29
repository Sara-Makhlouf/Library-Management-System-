import React, { useState, useCallback, useRef, useEffect } from "react";
import { Sparkles, Send, RotateCcw, AlertCircle, Bot, User } from "lucide-react";

/**
 * useAIChat
 * هوك شات بوت يسمح للمستخدم يسأل بلغة طبيعية عن بيانات الداشبورد.
 * يحتفظ بتاريخ المحادثة (سياق) ويرسله بالكامل مع كل سؤال جديد لـ Gemini،
 * لأن REST API بطبيعته بلا حالة (stateless) — لازم نرسل التاريخ يدوياً
 * في كل مرة عشان الموديل "يتذكر" الأسئلة السابقة.
 *
 * ⚠️ ملاحظة أمان: هذا الاستدعاء من المتصفح مباشرة، مناسب فقط
 * للتطوير المحلي/الديمو.
 */

const GEMINI_API_KEY = process.env.REACT_APP_GEMINI_API_KEY;
const GEMINI_MODEL = process.env.REACT_APP_GEMINI_MODEL || "gemini-2.5-flash-lite";
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

function buildDataContext({ salesSeries, borrowsSeries, topSellingBooks, totalOrdersCount, borrowsBreakdown }) {
  const salesSummary = (salesSeries || []).map((p) => `${p.label}: ${p.value}`).join(", ");
  const borrowsSummary = (borrowsSeries || []).map((p) => `${p.label}: ${p.value}`).join(", ");
  const topBooks = (topSellingBooks || [])
    .slice(0, 10)
    .map((b, i) => `${i + 1}. ${b.book_title} (${b.units_sold} sold)`)
    .join("\n");

  return `بيانات داشبورد المكتبة الحالية (استخدمها للإجابة على أسئلة المستخدم):
- إجمالي الطلبات المدفوعة: ${totalOrdersCount ?? "غير متوفر"}
- الاستعارة (مُرجَع/نشط/منتهي): ${borrowsBreakdown ? `${borrowsBreakdown.returned}/${borrowsBreakdown.active}/${borrowsBreakdown.expired}` : "غير متوفر"}
- المبيعات الأسبوعية: ${salesSummary || "لا بيانات"}
- الاستعارة الأسبوعية: ${borrowsSummary || "لا بيانات"}
- أكثر الكتب مبيعاً:
${topBooks || "لا بيانات"}`;
}

export function useAIChat() {
  // كل عنصر: { role: "user" | "model", text: string }
  const [messages, setMessages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const dataContextRef = useRef("");

  const sendMessage = useCallback(
    async (userText, dashboardData) => {
      if (!GEMINI_API_KEY) {
        setError("مفتاح Gemini غير موجود. أضف REACT_APP_GEMINI_API_KEY في ملف .env");
        return;
      }
      if (!userText || !userText.trim()) return;

      dataContextRef.current = buildDataContext(dashboardData);

      const newUserMessage = { role: "user", text: userText.trim() };
      const updatedMessages = [...messages, newUserMessage];
      setMessages(updatedMessages);
      setLoading(true);
      setError(null);

      try {
        const systemPreamble = `أنت مساعد ذكي تتكلم باللهجة العربية العادية المبسطة. تقدر تجاوب على أي سؤال عام بمعرفتك العادية.

بالإضافة لذلك، عندك بيانات داشبورد مكتبة معينة. لو سؤال المستخدم متعلق بهذه البيانات (مبيعات، استعارة، كتب، طلبات...)، استخدمها بدقة بالإجابة. لو السؤال عام وغير متعلق بالبيانات، جاوب عليه عادي من معرفتك العامة بدون أي إشارة لعدم توفر بيانات.

${dataContextRef.current}`;

        const contents = updatedMessages.map((m, i) => {
          const text = i === 0 ? `${systemPreamble}\n\nسؤال المستخدم: ${m.text}` : m.text;
          return {
            role: m.role === "model" ? "model" : "user",
            parts: [{ text }],
          };
        });

        const response = await fetch(GEMINI_URL, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-goog-api-key": GEMINI_API_KEY,
          },
          body: JSON.stringify({
            contents,
            generationConfig: {
              temperature: 0.5,
              maxOutputTokens: 500,
            },
          }),
        });

        if (!response.ok) {
          const errBody = await response.json().catch(() => null);
          throw new Error(errBody?.error?.message || `طلب فاشل (${response.status})`);
        }

        const data = await response.json();
        const rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

        if (!rawText) {
          throw new Error("لم يصل رد من الذكاء الاصطناعي");
        }

        setMessages((prev) => [...prev, { role: "model", text: rawText.trim() }]);
      } catch (err) {
        setError(err.message || "حدث خطأ أثناء المحادثة");
        setMessages((prev) => prev.slice(0, -1));
      } finally {
        setLoading(false);
      }
    },
    [messages]
  );

  const resetChat = useCallback(() => {
    setMessages([]);
    setError(null);
  }, []);

  return { messages, loading, error, sendMessage, resetChat };
}

/**
 * AIChatCard
 * شات بوت تفاعلي يسمح للمستخدم يسأل بلغته العادية عن بيانات الداشبورد
 * ("ليش المبيعات نازلة؟"، "شو أكثر كتاب مبيعاً؟"...) ويحتفظ بسياق المحادثة.
 */
export default function AIChatCard({ messages, loading, error, onSend, onReset }) {
  const [input, setInput] = useState("");
  const scrollRef = useRef(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages, loading]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!input.trim() || loading) return;
    onSend(input);
    setInput("");
  };

  const suggestions = [
    "ليش المبيعات نازلة؟",
    "شو أكثر كتاب مبيعاً؟",
    "كيف وضع الاستعارة هذا الأسبوع؟",
  ];

  return (
    <div style={styles.card}>
      <div style={styles.glow} />

      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 14, position: "relative" }}>
        <span style={styles.iconBadge}>
          <Sparkles size={14} />
        </span>
        <span style={styles.cardLabel}>AI ASSISTANT — اسأل عن بياناتك</span>

        {messages.length > 0 && (
          <button onClick={onReset} style={styles.resetBtn} title="محادثة جديدة">
            <RotateCcw size={13} />
          </button>
        )}
      </div>

      <div ref={scrollRef} style={styles.chatArea}>
        {messages.length === 0 ? (
          <div style={styles.emptyState}>
            <p style={styles.cardBody}>
              اسأل أي سؤال بلغتك العادية عن المبيعات أو الاستعارة أو الكتب الأكثر مبيعاً.
            </p>
            <div style={{ display: "flex", flexDirection: "column", gap: 6, marginTop: 10 }}>
              {suggestions.map((s, i) => (
                <button
                  key={i}
                  onClick={() => onSend(s)}
                  style={styles.suggestionBtn}
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        ) : (
          messages.map((m, i) => (
            <div
              key={i}
              style={{
                display: "flex",
                gap: 8,
                alignItems: "flex-start",
                flexDirection: m.role === "user" ? "row-reverse" : "row",
              }}
            >
              <span
                style={{
                  ...styles.avatar,
                  background: m.role === "user" ? "rgba(125,211,192,0.15)" : "rgba(167,139,250,0.18)",
                  color: m.role === "user" ? "#7dd3c0" : "#c4b5fd",
                }}
              >
                {m.role === "user" ? <User size={12} /> : <Bot size={12} />}
              </span>
              <div
                style={{
                  ...styles.bubble,
                  background: m.role === "user" ? "rgba(125,211,192,0.08)" : "rgba(167,139,250,0.1)",
                  border:
                    m.role === "user"
                      ? "1px solid rgba(125,211,192,0.2)"
                      : "1px solid rgba(167,139,250,0.2)",
                }}
              >
                {m.text}
              </div>
            </div>
          ))
        )}

        {loading && (
          <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
            <span style={{ ...styles.avatar, background: "rgba(167,139,250,0.18)", color: "#c4b5fd" }}>
              <Bot size={12} />
            </span>
            <div style={{ ...styles.bubble, background: "rgba(167,139,250,0.1)", border: "1px solid rgba(167,139,250,0.2)" }}>
              <span className="pulse-dot" style={{ display: "inline-block" }}>
                يفكر...
              </span>
            </div>
          </div>
        )}

        {error && (
          <div style={styles.errorBox}>
            <AlertCircle size={13} style={{ color: "#ff6b5e", flexShrink: 0 }} />
            <span style={{ fontSize: 12, color: "rgba(232,227,216,0.75)" }}>{error}</span>
          </div>
        )}
      </div>

      <form onSubmit={handleSubmit} style={styles.inputRow}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="اكتب سؤالك هنا..."
          disabled={loading}
          style={styles.input}
        />
        <button type="submit" disabled={loading || !input.trim()} style={styles.sendBtn}>
          <Send size={14} />
        </button>
      </form>
    </div>
  );
}

const styles = {
  card: {
    position: "relative",
    overflow: "hidden",
    padding: "20px 22px",
    borderRadius: 18,
    background: "linear-gradient(160deg, #1a1530 0%, #13121a 70%)",
    border: "1px solid rgba(167,139,250,0.28)",
    boxShadow: "0 0 0 1px rgba(167,139,250,0.05), 0 8px 30px -10px rgba(124,58,237,0.25)",
    display: "flex",
    flexDirection: "column",
  },
  glow: {
    position: "absolute",
    top: -60,
    right: -60,
    width: 160,
    height: 160,
    borderRadius: "50%",
    background: "radial-gradient(circle, rgba(167,139,250,0.25), transparent 70%)",
    pointerEvents: "none",
  },
  iconBadge: {
    width: 24,
    height: 24,
    borderRadius: 8,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "linear-gradient(135deg, #a78bfa, #7c3aed)",
    color: "#fff",
    flexShrink: 0,
  },
  cardLabel: {
    fontFamily: "'JetBrains Mono', monospace",
    fontSize: 11,
    letterSpacing: 0.6,
    color: "rgba(232,227,216,0.55)",
    fontWeight: 500,
  },
  resetBtn: {
    marginLeft: "auto",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "rgba(167,139,250,0.1)",
    border: "1px solid rgba(167,139,250,0.25)",
    color: "#c4b5fd",
    width: 28,
    height: 28,
    borderRadius: 8,
    cursor: "pointer",
    flexShrink: 0,
  },
  chatArea: {
    position: "relative",
    display: "flex",
    flexDirection: "column",
    gap: 10,
    minHeight: 180,
    maxHeight: 320,
    overflowY: "auto",
    paddingRight: 4,
    marginBottom: 14,
  },
  emptyState: {
    display: "flex",
    flexDirection: "column",
  },
  cardBody: {
    fontSize: 12.5,
    lineHeight: 1.55,
    color: "rgba(232,227,216,0.55)",
    margin: 0,
  },
  suggestionBtn: {
    textAlign: "right",
    background: "rgba(167,139,250,0.08)",
    border: "1px solid rgba(167,139,250,0.2)",
    color: "#c4b5fd",
    padding: "8px 12px",
    borderRadius: 10,
    fontSize: 12,
    cursor: "pointer",
  },
  avatar: {
    width: 22,
    height: 22,
    borderRadius: 999,
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
    marginTop: 2,
  },
  bubble: {
    fontSize: 12.5,
    lineHeight: 1.6,
    color: "rgba(232,227,216,0.92)",
    padding: "8px 12px",
    borderRadius: 12,
    maxWidth: "85%",
    whiteSpace: "pre-wrap",
  },
  errorBox: {
    display: "flex",
    alignItems: "flex-start",
    gap: 8,
    padding: "8px 10px",
    borderRadius: 10,
    background: "rgba(255,107,94,0.08)",
    border: "1px solid rgba(255,107,94,0.2)",
  },
  inputRow: {
    display: "flex",
    gap: 8,
    position: "relative",
  },
  input: {
    flex: 1,
    background: "rgba(255,255,255,0.05)",
    border: "1px solid rgba(255,255,255,0.1)",
    color: "#e8e3d8",
    padding: "10px 14px",
    borderRadius: 10,
    fontSize: 12.5,
    outline: "none",
    fontFamily: "'Inter', sans-serif",
  },
  sendBtn: {
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "linear-gradient(135deg, #a78bfa, #7c3aed)",
    border: "none",
    color: "#fff",
    width: 40,
    height: 40,
    borderRadius: 10,
    cursor: "pointer",
    flexShrink: 0,
  },
};