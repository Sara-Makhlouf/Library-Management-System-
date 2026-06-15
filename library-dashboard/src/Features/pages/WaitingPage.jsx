import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress, Tooltip, IconButton } from "@mui/material";
import { motion, AnimatePresence } from "framer-motion";
import { Hourglass, BookOpen, Phone, Calendar, Trash2, TrendingUp } from "lucide-react";

import { getBooksInvaliable, deleteFromWatingList, getTopWaitingList } from "../../Core/Redux/Thunks/WaitingListThunk";

const BG      = "#0a0a0f";
const SURFACE = "#111118";
const GOLD    = "#c9a84c";
const GOLD2   = "#8b5e1a";
const BORDER  = "rgba(255,255,255,0.06)";
const TEXT    = "#fff";
const MUTED   = "rgba(255,255,255,0.35)";
const MUTED2  = "rgba(255,255,255,0.20)";

const IMAGE_BASE_URL = "http://localhost:8000/storage/";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

const GRADIENTS = [
  "linear-gradient(135deg,#c9a84c,#8b5e1a)",
  "linear-gradient(135deg,#7f77dd,#4a43a0)",
  "linear-gradient(135deg,#1d9e75,#0f6b4f)",
  "linear-gradient(135deg,#97c459,#5f8e20)",
  "linear-gradient(135deg,#e06b5a,#a03322)",
];

const formatDate = (iso) => {
  if (!iso) return "—";
  return new Date(iso).toLocaleDateString("en-GB", { year: "numeric", month: "short", day: "numeric" });
};

export default function WaitingListPage() {
  const dispatch = useDispatch();
  const { items, pagination, topItems, loading } = useSelector((state) => state.waitingList) || {};

  useEffect(() => {
    dispatch(getBooksInvaliable());
    dispatch(getTopWaitingList());
  }, [dispatch]);

  const handleDelete = async (waitId) => {
    if (!window.confirm("Remove this entry from the waiting list?")) return;
    try {
      await dispatch(deleteFromWatingList(waitId)).unwrap();
    } catch (err) {
      console.error("Failed to delete waiting list entry:", err);
    }
  };

  if (loading && (!items || items.length === 0)) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: BG, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <CircularProgress sx={{ color: GOLD }} />
      </Box>
    );
  }

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      <Box
        sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          mb: 3, px: "20px", height: 60,
          bgcolor: "rgba(255,255,255,0.04)",
          border: `1px solid ${BORDER}`,
          borderRadius: "16px",
          position: "sticky", top: 0, zIndex: 10,
          backdropFilter: "blur(16px)",
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box
            sx={{
              width: 32, height: 32, borderRadius: "10px",
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              display: "flex", alignItems: "center", justifyContent: "center",
            }}
          >
            <Hourglass size={16} color="#fff" />
          </Box>
          <Typography sx={{ fontWeight: 700, fontSize: 15, color: TEXT, letterSpacing: -0.3 }}>
            Waiting List
          </Typography>
        </Box>

        <Box sx={{
          px: "12px", py: "5px", borderRadius: "8px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11.5, fontWeight: 700, color: GOLD,
        }}>
          {pagination?.total ?? items?.length ?? 0} waiting
        </Box>
      </Box>

      <Box
        sx={{
          p: { xs: 3, md: "36px 40px" },
          borderRadius: "20px",
          background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
          border: "1px solid rgba(201,168,76,0.2)",
          position: "relative", overflow: "hidden",
          mb: 2.5,
        }}
      >
        <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: -60, left: -40, width: 200, height: 200, background: "radial-gradient(circle,rgba(139,94,26,0.06) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

        <Box sx={{
          display: "inline-flex", alignItems: "center", gap: "6px",
          mb: 2.5, px: "12px", py: "4px", borderRadius: "20px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11, fontWeight: 600, letterSpacing: 0.5, color: GOLD,
        }}>
          ● Pending Borrows
        </Box>

        <Typography
          sx={{
            fontSize: { xs: 24, md: 32 }, fontWeight: 800,
            letterSpacing: -1, lineHeight: 1.1, mb: 1.5,
            background: `linear-gradient(135deg,${TEXT} 0%,${GOLD} 100%)`,
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text",
          }}
        >
          Customers waiting for books
        </Typography>

        <Typography sx={{ fontSize: 14, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 440 }}>
          Track which customers are waiting for currently unavailable titles, and remove entries once resolved.
        </Typography>
      </Box>

      {topItems?.length > 0 && (
        <Box
          component={motion.div}
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          sx={{
            p: "20px", borderRadius: "18px",
            bgcolor: SURFACE, border: `1px solid ${BORDER}`,
            mb: 2.5,
          }}
        >
          <Box sx={{ display: "flex", alignItems: "center", gap: 1.2, mb: 2.5 }}>
            <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: "rgba(201,168,76,0.18)", color: GOLD, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <TrendingUp size={15} />
            </Box>
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
              Most Waited-For Books
            </Typography>
          </Box>

          {(() => {
            const maxCount = topItems[0]?.waiting_count || 1;
            return topItems.map((top, i) => {
              const pct = Math.round(((top.waiting_count || 0) / maxCount) * 100);
              return (
                <Box
                  key={top.book_id}
                  sx={{
                    display: "flex", alignItems: "center", gap: 1.5,
                    py: 1.2, px: 1, borderRadius: "10px", mb: 0.5,
                    transition: "all 0.2s",
                    "&:hover": { bgcolor: "rgba(255,255,255,0.04)" },
                  }}
                >
                  <Box sx={{
                    minWidth: 26, height: 26, borderRadius: "7px",
                    bgcolor: i === 0 ? "rgba(201,168,76,0.15)" : "rgba(255,255,255,0.05)",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 11, fontWeight: 800,
                    color: i === 0 ? GOLD : "rgba(255,255,255,0.2)",
                  }}>
                    {i + 1}
                  </Box>

                  <Box sx={{ flex: 1, minWidth: 0 }}>
                    <Typography sx={{
                      fontWeight: 600, fontSize: 13, color: TEXT,
                      whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis",
                    }}>
                      {top.book?.title}
                    </Typography>
                    <Typography sx={{ fontSize: 11, color: MUTED2 }}>
                      {top.waiting_count} waiting
                    </Typography>
                  </Box>

                  <Box sx={{ width: 70 }}>
                    <Box sx={{ height: 3, borderRadius: 2, bgcolor: "rgba(255,255,255,0.07)", overflow: "hidden" }}>
                      <Box sx={{ height: "100%", width: `${pct}%`, bgcolor: i === 0 ? GOLD : "rgba(255,255,255,0.2)", borderRadius: 2 }} />
                    </Box>
                  </Box>
                </Box>
              );
            });
          })()}
        </Box>
      )}

      {items?.length > 0 ? (
        <Box sx={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 2 }}>
          <AnimatePresence mode="wait">
            {items.map((entry, i) => (
              <Box
                key={entry.id}
                component={motion.div}
                layout
                initial={{ opacity: 0, scale: 0.96 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.96 }}
                transition={{ duration: 0.18 }}
                sx={{
                  borderRadius: "18px",
                  bgcolor: SURFACE, border: `1px solid ${BORDER}`,
                  overflow: "hidden",
                  transition: "all 0.25s",
                  "&:hover": { borderColor: `${GOLD}40`, transform: "translateY(-3px)", bgcolor: "#151520" },
                }}
              >
                <Box sx={{ aspectRatio: "3/1.4", bgcolor: "rgba(255,255,255,0.02)", position: "relative", overflow: "hidden" }}>
                  <Box
                    component="img"
                    src={entry.book?.cover ? `${IMAGE_BASE_URL}${entry.book.cover}` : "/history book.jpg"}
                    sx={{ width: "100%", height: "100%", objectFit: "cover" }}
                  />
                  {entry.book?.is_digital && (
                    <Box sx={{
                      position: "absolute", top: 10, right: 10,
                      px: 1.2, py: 0.3, borderRadius: "6px",
                      bgcolor: "rgba(127,119,221,0.15)",
                    }}>
                      <Typography sx={{ fontSize: 10, fontWeight: 700, letterSpacing: 0.5, color: "#7f77dd" }}>
                        DIGITAL
                      </Typography>
                    </Box>
                  )}

                  <Tooltip title="Remove from waiting list" arrow>
                    <IconButton
                      size="small"
                      onClick={() => handleDelete(entry.id)}
                      sx={{
                        position: "absolute", top: 10, left: 10,
                        borderRadius: "8px",
                        bgcolor: "rgba(0,0,0,0.4)",
                        border: `1px solid ${BORDER}`,
                        color: "#f87171",
                        "&:hover": { bgcolor: "rgba(248,113,113,0.2)", borderColor: "rgba(248,113,113,0.4)" },
                        transition: "all 0.2s",
                      }}
                    >
                      <Trash2 size={14} />
                    </IconButton>
                  </Tooltip>
                </Box>

                <Box sx={{ p: "14px 16px" }}>
                  <Box sx={{ display: "flex", alignItems: "flex-start", gap: 1, mb: 1.5 }}>
                    <BookOpen size={14} color={GOLD} style={{ marginTop: 2, flexShrink: 0 }} />
                    <Typography sx={{
                      fontWeight: 700, fontSize: 13, color: TEXT, lineHeight: 1.4,
                      display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical", overflow: "hidden",
                    }}>
                      {entry.book?.title}
                    </Typography>
                  </Box>

                  <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 1, pt: 1.5, borderTop: `1px solid ${BORDER}` }}>
                    <Box sx={{
                      width: 28, height: 28, borderRadius: "8px",
                      background: GRADIENTS[i % GRADIENTS.length],
                      display: "flex", alignItems: "center", justifyContent: "center",
                      fontSize: 11, fontWeight: 700, color: "#fff", flexShrink: 0,
                    }}>
                      {initials(entry.customer?.name)}
                    </Box>
                    <Box sx={{ minWidth: 0 }}>
                      <Typography sx={{ fontSize: 12.5, fontWeight: 600, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                        {entry.customer?.name}
                      </Typography>
                      <Typography sx={{ fontSize: 11, color: MUTED, display: "flex", alignItems: "center", gap: 0.5 }}>
                        <Phone size={10} /> {entry.customer?.phone}
                      </Typography>
                    </Box>
                  </Box>

                  <Typography sx={{ fontSize: 11, color: MUTED2, display: "flex", alignItems: "center", gap: 0.5, mt: 1 }}>
                    <Calendar size={11} /> Requested {formatDate(entry.created_at)}
                  </Typography>
                </Box>
              </Box>
            ))}
          </AnimatePresence>
        </Box>
      ) : (
        <Box sx={{ textAlign: "center", py: 8 }}>
          <Typography sx={{ fontSize: 13, color: MUTED }}>No customers are currently waiting.</Typography>
        </Box>
      )}
    </Box>
  );
}