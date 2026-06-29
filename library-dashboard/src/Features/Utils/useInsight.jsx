import { useState, useCallback, useRef } from "react";

/**
 * useAIChat
 * هوك شات بوت يسمح للمستخدم يسأل بلغة طبيعية عن بيانات الداشبورد.
 * يحتفظ بتاريخ المحادثة (سياق) ويرسله بالكامل مع كل سؤال جديد لـ Gemini،
 * لأن REST API بطبيعته بلا حالة (stateless) — لازم نرسل التاريخ يدوياً
 * في كل مرة عشان الموديل "يتذكر" الأسئلة السابقة.
 *
 * ⚠️ ملاحظة أمان: هذا الاستدعاء من المتصفح مباشرة، مناسب فقط
 * للتطوير المحلي/الديمو. راجع التعليق بأعلى ملف useAIInsights.js
 * القديم لتفاصيل أكثر حول هذه النقطة.
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

      // نحدّث سياق البيانات في كل سؤال، عشان لو تغيّرت بيانات الداشبورد
      // (بعد ضغط Refresh مثلاً) يصير عند الموديل أحدث نسخة.
      dataContextRef.current = buildDataContext(dashboardData);

      const newUserMessage = { role: "user", text: userText.trim() };
      const updatedMessages = [...messages, newUserMessage];
      setMessages(updatedMessages);
      setLoading(true);
      setError(null);

      try {
     const systemPreamble = `أنت مساعد ذكي ومفيد تتكلم باللهجة العربية العادية المبسطة، تماماً متل Gemini.

جاوب على أي سؤال يسألك المستخدم من معرفتك العامة — طقس، أبراج، جغرافيا، علوم، ترفيه، نكت، أي شي — بشكل طبيعي وودي.

بالإضافة لذلك، عندك بيانات داشبورد مكتبة. لو السؤال متعلق فيها، استخدمها:
${dataContextRef.current}`;

        // أول رسالة بالمحادثة منرسلها مدموجة مع سياق البيانات والتعليمات.
        // الرسائل اللي بعدها منرسلها كما هي، لأن السياق صار موجود بتاريخ المحادثة أصلاً.
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
        // نحذف رسالة المستخدم الأخيرة من العرض لو فشل الطلب، عشان يقدر يعيد المحاولة
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