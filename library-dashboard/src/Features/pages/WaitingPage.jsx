import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  Box,
  Typography,
  CircularProgress,
  Tooltip,
  IconButton,
  Dialog,
  DialogContent,
  DialogActions,
  Button,
} from "@mui/material";
import { motion, AnimatePresence } from "framer-motion";
import { Hourglass, Phone, Calendar, Trash2, TrendingUp, TriangleAlert, BookMarked } from "lucide-react";

import { getBooksInvaliable, deleteFromWatingList, getTopWaitingList } from "../../Core/Redux/Thunks/WaitingListThunk";
import {GOLD ,SURFACE,MUTED2,MUTED,TEXT,IMAGE_BASE_URL ,BORDER,BG,GOLD2} from "../../Core/Constants/utils";


const FONT_IMPORT_ID = "lib-fonts";
const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (document.getElementById(FONT_IMPORT_ID)) return;
  const link = document.createElement("link");
  link.id = FONT_IMPORT_ID;
  link.rel = "stylesheet";
  link.href = FONT_HREF;
  document.head.appendChild(link);
}

const display = { fontFamily: "'Fraunces', serif" };
const mono = { fontFamily: "'IBM Plex Mono', monospace" };

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

const daysWaiting = (iso) => {
  if (!iso) return null;
  const diff = Date.now() - new Date(iso).getTime();
  return Math.max(0, Math.floor(diff / (1000 * 60 * 60 * 24)));
};

export default function WaitingListPage() {
  const dispatch = useDispatch();
  const { items, pagination, topItems, loading } = useSelector((state) => state.waitingList) || {};
  const [deleteEntry, setDeleteEntry] = useState(null);
  const [deleting, setDeleting] = useState(false);

  useEffect(() => { injectFonts(); }, []);

  useEffect(() => {
    dispatch(getBooksInvaliable());
    dispatch(getTopWaitingList());
  }, [dispatch]);

 const handleConfirmDelete = async () => {
  if (!deleteEntry) return;
  setDeleting(true);
  try {
    await dispatch(deleteFromWatingList(deleteEntry.id)).unwrap();
    setDeleteEntry(null);
    dispatch(getBooksInvaliable());
    dispatch(getTopWaitingList());  
  } catch (err) {
    console.error("Failed to delete waiting list entry:", err);
  } finally {
    setDeleting(false);
  }
};

  const sortedItems = [...(items || [])].sort(
    (a, b) => new Date(a.created_at || 0) - new Date(b.created_at || 0)
  );

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
          <Typography sx={{ ...display, fontWeight: 600, fontSize: 16, color: TEXT, letterSpacing: -0.2 }}>
            Waiting List
          </Typography>
        </Box>

        <Box sx={{
          ...mono,
          px: "12px", py: "5px", borderRadius: "8px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11.5, fontWeight: 600, color: GOLD,
        }}>
          {pagination?.total ?? items?.length ?? 0} waiting
        </Box>
      </Box>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: topItems?.length > 0 ? "1fr 320px" : "1fr" },
          gap: 2, mb: 2.5,
        }}
      >
        <Box
          sx={{
            p: { xs: 3, md: "32px 36px" },
            borderRadius: "20px",
            background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
            border: "1px solid rgba(201,168,76,0.2)",
            position: "relative", overflow: "hidden",
          }}
        >
          <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
          <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

          <Box sx={{
            display: "inline-flex", alignItems: "center", gap: "6px",
            mb: 2.2, px: "12px", py: "4px", borderRadius: "20px",
            bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
            fontSize: 11, fontWeight: 600, letterSpacing: 0.5, color: GOLD,
          }}>
            ● Pending Borrows
          </Box>

          <Typography
            sx={{
              ...display,
              fontSize: { xs: 24, md: 30 }, fontWeight: 600,
              letterSpacing: -0.5, lineHeight: 1.15, mb: 1.3,
              color: TEXT,
            }}
          >
            Customers waiting <Box component="span" sx={{ color: GOLD, fontStyle: "italic" }}>for books</Box>
          </Typography>

          <Typography sx={{ fontSize: 13.5, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 420 }}>
            Ordered by who's been waiting longest. Remove an entry once it's resolved.
          </Typography>
        </Box>

        {topItems?.length > 0 && (
          <Box
            component={motion.div}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            sx={{
              p: "18px", borderRadius: "18px",
              bgcolor: SURFACE, border: `1px solid ${BORDER}`,
            }}
          >
            <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 2 }}>
              <Box sx={{ width: 24, height: 24, borderRadius: "7px", bgcolor: "rgba(201,168,76,0.18)", color: GOLD, display: "flex", alignItems: "center", justifyContent: "center" }}>
                <TrendingUp size={13} />
              </Box>
              <Typography sx={{ fontSize: 11.5, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.4, textTransform: "uppercase" }}>
                Most Waited-For
              </Typography>
            </Box>

            {(() => {
              const maxCount = topItems[0]?.waiting_count || 1;
              return topItems.slice(0, 4).map((top, i) => {
                const pct = Math.round(((top.waiting_count || 0) / maxCount) * 100);
                return (
                  <Box key={top.book_id} sx={{ mb: i < topItems.length - 1 ? 1.6 : 0 }}>
                    <Box sx={{ display: "flex", justifyContent: "space-between", mb: 0.5 }}>
                      <Typography sx={{ fontSize: 12, fontWeight: 600, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 190 }}>
                        {top.book?.title}
                      </Typography>
                      <Typography sx={{ ...mono, fontSize: 11, color: i === 0 ? GOLD : MUTED2, flexShrink: 0, ml: 1 }}>
                        {top.waiting_count}
                      </Typography>
                    </Box>
                    <Box sx={{ height: 3, borderRadius: 2, bgcolor: "rgba(255,255,255,0.07)", overflow: "hidden" }}>
                      <Box sx={{ height: "100%", width: `${pct}%`, bgcolor: i === 0 ? GOLD : "rgba(255,255,255,0.2)", borderRadius: 2 }} />
                    </Box>
                  </Box>
                );
              });
            })()}
          </Box>
        )}
      </Box>

      {sortedItems.length > 0 ? (
        <Box sx={{ bgcolor: SURFACE, border: `1px solid ${BORDER}`, borderRadius: "18px", overflow: "hidden" }}>
          <Box sx={{
            display: "grid", gridTemplateColumns: "32px 1fr 1fr 110px 40px",
            px: "18px", py: "10px", gap: 1.5,
            bgcolor: "rgba(255,255,255,0.02)", borderBottom: `1px solid ${BORDER}`,
          }}>
            {["#", "Book", "Customer", "Waiting since", ""].map((h) => (
              <Typography key={h} sx={{ fontSize: 10, fontWeight: 600, color: "rgba(255,255,255,0.25)", letterSpacing: "0.8px", textTransform: "uppercase" }}>
                {h}
              </Typography>
            ))}
          </Box>

          <AnimatePresence mode="wait">
            {sortedItems.map((entry, i) => {
              const wait = daysWaiting(entry.created_at);
              return (
                <Box
                  key={entry.id}
                  component={motion.div}
                  layout
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  transition={{ duration: 0.15 }}
                  sx={{
                    display: "grid", gridTemplateColumns: "32px 1fr 1fr 110px 40px",
                    px: "18px", py: "12px", gap: 1.5, alignItems: "center",
                    borderBottom: i < sortedItems.length - 1 ? `1px solid ${BORDER}` : "none",
                    transition: "background .15s",
                    "&:hover": { bgcolor: "rgba(255,255,255,0.02)" },
                  }}
                >
                  <Typography sx={{ ...mono, fontSize: 11.5, color: MUTED2, fontWeight: 600 }}>
                    {String(i + 1).padStart(2, "0")}
                  </Typography>

                  <Box sx={{ display: "flex", alignItems: "center", gap: 1.2, minWidth: 0 }}>
                    <Box
                      component="img"
                      src={entry.book?.cover ? `${IMAGE_BASE_URL}${entry.book.cover}` : "/history book.jpg"}
                      sx={{ width: 30, height: 40, objectFit: "cover", borderRadius: "5px", flexShrink: 0, boxShadow: "0 4px 10px rgba(0,0,0,0.3)" }}
                    />
                    <Box sx={{ minWidth: 0 }}>
                      <Typography sx={{ ...display, fontWeight: 600, fontSize: 13, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                        {entry.book?.title}
                      </Typography>
                      {entry.book?.is_digital && (
                        <Typography sx={{ ...mono, fontSize: 9, fontWeight: 600, letterSpacing: 0.4, color: "#7f77dd" }}>
                          DIGITAL
                        </Typography>
                      )}
                    </Box>
                  </Box>

                  <Box sx={{ display: "flex", alignItems: "center", gap: 1, minWidth: 0 }}>
                    <Box sx={{
                      width: 24, height: 24, borderRadius: "7px", flexShrink: 0,
                      background: GRADIENTS[i % GRADIENTS.length],
                      display: "flex", alignItems: "center", justifyContent: "center",
                      fontSize: 10, fontWeight: 700, color: "#fff",
                    }}>
                      {initials(entry.customer?.name)}
                    </Box>
                    <Box sx={{ minWidth: 0 }}>
                      <Typography sx={{ fontSize: 12.5, fontWeight: 600, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                        {entry.customer?.name}
                      </Typography>
                      <Typography sx={{ ...mono, fontSize: 10, color: MUTED, display: "flex", alignItems: "center", gap: 0.4 }}>
                        <Phone size={9} /> {entry.customer?.phone}
                      </Typography>
                    </Box>
                  </Box>

                  <Box>
                    <Typography sx={{ fontSize: 11.5, color: MUTED, display: "flex", alignItems: "center", gap: 0.5 }}>
                      <Calendar size={11} /> {formatDate(entry.created_at)}
                    </Typography>
                    {wait !== null && (
                      <Typography sx={{ ...mono, fontSize: 9.5, color: wait > 14 ? "#f87171" : MUTED2, mt: 0.2 }}>
                        {wait}d
                      </Typography>
                    )}
                  </Box>

                  <Tooltip title="Remove from waiting list" arrow>
                    <IconButton
                      size="small"
                      onClick={() => setDeleteEntry(entry)}
                      sx={{
                        borderRadius: "8px",
                        color: "rgba(248,113,113,0.6)",
                        "&:hover": { bgcolor: "rgba(248,113,113,0.12)", color: "#f87171" },
                        transition: "all 0.2s",
                      }}
                    >
                      <Trash2 size={15} />
                    </IconButton>
                  </Tooltip>
                </Box>
              );
            })}
          </AnimatePresence>
        </Box>
      ) : (
        <Box sx={{ textAlign: "center", py: 8 }}>
          <Box sx={{ display: "inline-flex", width: 44, height: 44, borderRadius: "12px", bgcolor: "rgba(255,255,255,0.04)", alignItems: "center", justifyContent: "center", mb: 1.5 }}>
            <BookMarked size={20} color={MUTED2} />
          </Box>
          <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: "rgba(255,255,255,0.35)", mb: 0.5 }}>
            No one's waiting
          </Typography>
          <Typography sx={{ fontSize: 12, color: MUTED2 }}>
            No customers are currently waiting for a book.
          </Typography>
        </Box>
      )}

      <Dialog
        open={Boolean(deleteEntry)}
        onClose={() => !deleting && setDeleteEntry(null)}
        PaperProps={{
          sx: {
            borderRadius: "20px",
            minWidth: "380px",
            maxWidth: "420px",
            bgcolor: "#1a1a24",
            border: "1px solid rgba(248,113,113,0.18)",
            boxShadow: "0 24px 60px rgba(0,0,0,0.5)",
          },
        }}
      >
        <DialogContent sx={{ p: "28px 26px 8px" }}>
          <Box
            sx={{
              width: 44, height: 44, borderRadius: "12px",
              bgcolor: "rgba(248,113,113,0.12)",
              display: "flex", alignItems: "center", justifyContent: "center",
              mb: 2,
            }}
          >
            <TriangleAlert size={20} color="#f87171" />
          </Box>

          <Typography sx={{ ...display, fontSize: 17, fontWeight: 600, color: TEXT, mb: 0.8 }}>
            Remove from waiting list?
          </Typography>
          <Typography sx={{ fontSize: 13, color: MUTED, lineHeight: 1.6, mb: 2.2 }}>
            They'll need to rejoin the list if they're still interested in this book.
          </Typography>

          {deleteEntry && (
            <Box
              sx={{
                display: "flex", alignItems: "center", gap: 1.4,
                p: "10px 12px", borderRadius: "12px",
                bgcolor: "rgba(255,255,255,0.03)",
                border: `1px solid ${BORDER}`,
              }}
            >
              <Box
                component="img"
                src={deleteEntry.book?.cover ? `${IMAGE_BASE_URL}${deleteEntry.book.cover}` : "/history book.jpg"}
                sx={{ width: 36, height: 48, objectFit: "cover", borderRadius: "6px", flexShrink: 0 }}
              />
              <Box sx={{ minWidth: 0 }}>
                <Typography sx={{ ...display, fontWeight: 600, fontSize: 13, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                  {deleteEntry.book?.title}
                </Typography>
                <Typography sx={{ fontSize: 11, color: MUTED2, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                  Waiting: {deleteEntry.customer?.name}
                </Typography>
              </Box>
            </Box>
          )}
        </DialogContent>

        <DialogActions sx={{ px: "26px", pb: "24px", pt: 2, gap: 1 }}>
          <Button
            onClick={() => setDeleteEntry(null)}
            disabled={deleting}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 600,
              fontSize: 13.5, color: MUTED,
              border: `1px solid ${BORDER}`, px: 2.5,
              "&:hover": { bgcolor: "rgba(255,255,255,0.05)", color: TEXT },
            }}
          >
            Cancel
          </Button>
          <Button
            onClick={handleConfirmDelete}
            disabled={deleting}
            variant="contained"
            disableElevation
            startIcon={!deleting ? <Trash2 size={15} /> : null}
            sx={{
              borderRadius: "10px", textTransform: "none",
              fontWeight: 700, fontSize: 13.5, px: 2.8,
              color: "#fff",
              background: "linear-gradient(135deg,#f87171,#c83737)",
              "&:hover": {
                background: "linear-gradient(135deg,#fb8585,#d94545)",
                boxShadow: "0 12px 28px rgba(248,113,113,0.25)",
              },
              "&.Mui-disabled": { color: "rgba(255,255,255,0.6)" },
            }}
          >
            {deleting ? <CircularProgress size={16} sx={{ color: "#fff" }} /> : "Remove"}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}