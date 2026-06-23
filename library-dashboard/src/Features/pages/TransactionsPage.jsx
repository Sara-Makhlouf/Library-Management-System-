import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  Box, Typography, CircularProgress,
  Dialog, DialogContent, DialogActions,
  Button, TextField, MenuItem,
} from "@mui/material";
import { getAllTransactions, checkoutTransaction } from "../../Core/Redux/Thunks/TranscationThunk";
import toast from "react-hot-toast";

const BG      = "#0a0a0f";
const SURFACE = "#111118";
const GOLD    = "#c9a84c";
const GOLD2   = "#8b5e1a";
const BORDER  = "rgba(255,255,255,0.06)";
const TEXT    = "#fff";
const MUTED   = "rgba(255,255,255,0.35)";
const MUTED2  = "rgba(255,255,255,0.20)";

const display = { fontFamily: "'Fraunces', serif" };
const mono    = { fontFamily: "'IBM Plex Mono', monospace" };

const FONT_IMPORT_ID = "lib-fonts";
const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (document.getElementById(FONT_IMPORT_ID)) return;
  const link = document.createElement("link");
  link.id   = FONT_IMPORT_ID;
  link.rel  = "stylesheet";
  link.href = FONT_HREF;
  document.head.appendChild(link);
}

const GRADIENTS = [
  "linear-gradient(135deg,#c9a84c,#8b5e1a)",
  "linear-gradient(135deg,#7f77dd,#4a43a0)",
  "linear-gradient(135deg,#1d9e75,#0f6b4f)",
  "linear-gradient(135deg,#97c459,#5f8e20)",
  "linear-gradient(135deg,#e06b5a,#a03322)",
];

const COL = "70px 1.3fr 0.9fr 0.8fr 0.9fr 0.9fr 0.9fr 0.9fr 0.9fr 90px";

const fmt = (val) =>
  parseFloat(val || 0).toLocaleString("en-US", { minimumFractionDigits: 2 });

const fmtDate = (iso) =>
  iso ? new Date(iso).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" }) : "—";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

const STATUS = {
  received: { color: "#4ade80", bg: "rgba(74,222,128,0.1)",  border: "rgba(74,222,128,0.25)"  },
  sold:     { color: GOLD,      bg: "rgba(201,168,76,0.1)",  border: "rgba(201,168,76,0.25)"  },
  returned: { color: "#7f77dd", bg: "rgba(127,119,221,0.1)", border: "rgba(127,119,221,0.25)" },
  default:  { color: MUTED,     bg: "rgba(255,255,255,0.05)", border: BORDER                  },
};

function Avatar({ name, index, size = 30 }) {
  return (
    <Box sx={{
      width: size, height: size, minWidth: size,
      borderRadius: "9px",
      background: GRADIENTS[index % GRADIENTS.length],
      display: "flex", alignItems: "center", justifyContent: "center",
      fontSize: size * 0.36, fontWeight: 700, color: TEXT,
    }}>
      {initials(name)}
    </Box>
  );
}

function StatusChip({ status }) {
  const s = STATUS[status] ?? STATUS.default;
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center", gap: "5px",
      px: "9px", py: "3px", borderRadius: "6px",
      fontSize: 11, fontWeight: 600,
      bgcolor: s.bg, border: `1px solid ${s.border}`, color: s.color,
    }}>
      <Box sx={{ width: 5, height: 5, borderRadius: "50%", bgcolor: "currentColor" }} />
      {status}
    </Box>
  );
}

function TypeChip({ type }) {
  const isBorrow = type === "borrow";
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center",
      px: "9px", py: "3px", borderRadius: "6px",
      fontSize: 11, fontWeight: 600,
      ...(isBorrow
        ? { bgcolor: "rgba(201,168,76,0.08)", border: `1px solid rgba(201,168,76,0.2)`, color: GOLD }
        : { bgcolor: "rgba(29,158,117,0.08)", border: `1px solid rgba(29,158,117,0.2)`, color: "#1d9e75" }),
    }}>
      {isBorrow ? "📖 Borrow" : "🛒 Buy"}
    </Box>
  );
}

function DateCell({ value }) {
  return (
    <Typography sx={{ fontSize: 11.5, color: value ? MUTED : MUTED2, display: "flex", alignItems: "center", gap: "4px" }}>
      📅 {fmtDate(value)}
    </Typography>
  );
}

const inputSx = {
  mb: 1.5,
  "& .MuiFilledInput-root": {
    bgcolor: "rgba(255,255,255,0.04)",
    borderRadius: "10px",
    border: `1px solid ${BORDER}`,
    color: TEXT,
    fontFamily: "Inter, sans-serif",
    "&:hover": { bgcolor: "rgba(255,255,255,0.06)" },
    "&.Mui-focused": { bgcolor: "rgba(255,255,255,0.06)", border: `1px solid rgba(201,168,76,0.4)` },
    "&:before, &:after": { display: "none" },
  },
  "& .MuiInputLabel-root": { color: MUTED, fontFamily: "Inter, sans-serif" },
  "& .MuiInputLabel-root.Mui-focused": { color: GOLD },
  "& .MuiSelect-icon": { color: MUTED },
};

function Pagination({ currentPage, totalPages, onPageChange }) {
  if (totalPages <= 1) return null;

  const pages = Array.from({ length: totalPages }, (_, i) => i + 1);

  const btnBase = {
    display: "flex", alignItems: "center", justifyContent: "center",
    borderRadius: "10px", cursor: "pointer", userSelect: "none",
    fontSize: 13, fontWeight: 700, transition: "all .15s",
  };

  return (
    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 1, mt: 2.5 }}>
      <Box
        onClick={() => currentPage > 1 && onPageChange(currentPage - 1)}
        sx={{
          ...btnBase,
          px: "14px", height: 36,
          bgcolor: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`,
          color: currentPage === 1 ? MUTED2 : MUTED,
          cursor: currentPage === 1 ? "not-allowed" : "pointer",
          "&:hover": currentPage > 1 ? { bgcolor: "rgba(255,255,255,0.08)", color: TEXT } : {},
        }}
      >
        ← Prev
      </Box>

      {pages.map((page) => (
        <Box
          key={page}
          onClick={() => onPageChange(page)}
          sx={{
            ...btnBase,
            width: 36, height: 36,
            ...(page === currentPage
              ? { background: `linear-gradient(135deg,${GOLD},${GOLD2})`, color: "#000" }
              : {
                  bgcolor: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`, color: MUTED,
                  "&:hover": { bgcolor: "rgba(255,255,255,0.08)", color: TEXT },
                }),
          }}
        >
          {page}
        </Box>
      ))}

      <Box
        onClick={() => currentPage < totalPages && onPageChange(currentPage + 1)}
        sx={{
          ...btnBase,
          px: "14px", height: 36,
          bgcolor: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`,
          color: currentPage === totalPages ? MUTED2 : MUTED,
          cursor: currentPage === totalPages ? "not-allowed" : "pointer",
          "&:hover": currentPage < totalPages ? { bgcolor: "rgba(255,255,255,0.08)", color: TEXT } : {},
        }}
      >
        Next →
      </Box>
    </Box>
  );
}

export default function TransactionsPage() {
  const dispatch = useDispatch();
  const { transactions, pagination, loading } = useSelector((state) => state.Transcation);

  const [currentPage, setCurrentPage] = useState(1);
  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({
    bill_id: "", book_id: "", type: "borrow", days: 7, payment_method: "cash",
  });

  useEffect(() => { injectFonts(); }, []);

  useEffect(() => {
    dispatch(getAllTransactions({ page: currentPage }));
  }, [dispatch, currentPage]);

  const handlePageChange = (page) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleCheckout = async () => {
    const payload = {
      bill_id: parseInt(formData.bill_id),
      items: [{
        book_id:        parseInt(formData.book_id),
        action_type:    formData.type,
        days:           parseInt(formData.days),
        payment_method: formData.payment_method,
      }],
    };
    try {
      await dispatch(checkoutTransaction(payload)).unwrap();
      toast.success("Added successfully! ✅");
      setOpen(false);
      dispatch(getAllTransactions({ page: currentPage }));
    } catch (err) {
      const errorMsg = err?.errors?.["items.0.action_type"]?.[0] ?? "Error sending ❌";
      toast.error(errorMsg);
    }
  };

  const rows = Array.isArray(transactions) ? transactions : [];
  const totalPages  = pagination?.lastPage    ?? 1;
  const totalCount  = pagination?.total       ?? rows.length;

  const totalRevenue = rows.reduce((s, r) => s + parseFloat(r.price || 0), 0);
  const borrows      = rows.filter((r) => r.type === "borrow").length;
  const buys         = rows.filter((r) => r.type === "buy").length;

  if (loading && rows.length === 0) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: BG, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <CircularProgress sx={{ color: GOLD }} />
      </Box>
    );
  }

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      <Box sx={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        mb: 3, px: "20px", height: 60,
        bgcolor: "rgba(255,255,255,0.04)",
        border: `1px solid ${BORDER}`,
        borderRadius: "16px",
        position: "sticky", top: 0, zIndex: 10,
        backdropFilter: "blur(16px)",
      }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box sx={{
            width: 32, height: 32, borderRadius: "10px",
            background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 15,
          }}>
            🔁
          </Box>
          <Typography sx={{ ...display, fontWeight: 600, fontSize: 16, color: TEXT, letterSpacing: -0.2 }}>
            Transactions
          </Typography>
        </Box>

        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box sx={{
            ...mono,
            px: "12px", py: "5px", borderRadius: "8px",
            bgcolor: "rgba(201,168,76,0.1)", border: `1px solid rgba(201,168,76,0.2)`,
            fontSize: 11.5, fontWeight: 600, color: GOLD,
          }}>
            {totalCount} total
          </Box>
          <Box
            onClick={() => setOpen(true)}
            sx={{
              display: "flex", alignItems: "center", gap: "6px",
              px: "14px", py: "6px", borderRadius: "10px",
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              cursor: "pointer", userSelect: "none",
              transition: "opacity .15s",
              "&:hover": { opacity: 0.88 },
            }}
          >
            <Typography sx={{ ...mono, fontSize: 12, fontWeight: 700, color: "#000" }}>
              + New Checkout
            </Typography>
          </Box>
        </Box>
      </Box>

      {rows.length > 0 && (
        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "repeat(3,1fr)" }, gap: 2, mb: 2.5 }}>
          {[
            { label: "Page Revenue", value: fmt(totalRevenue), unit: "SYP", gold: true },
            { label: "Borrows",      value: borrows,           unit: "this page"        },
            { label: "Sales",        value: buys,              unit: "this page"        },
          ].map(({ label, value, unit, gold }) => (
            <Box key={label} sx={{ bgcolor: SURFACE, border: `1px solid ${BORDER}`, borderRadius: "16px", p: "18px 20px" }}>
              <Typography sx={{ ...mono, fontSize: 10, fontWeight: 600, letterSpacing: "0.7px", color: MUTED2, textTransform: "uppercase", mb: "8px" }}>
                {label}
              </Typography>
              <Typography sx={{ ...display, fontSize: 26, fontWeight: 600, color: gold ? GOLD : TEXT, letterSpacing: "-0.5px" }}>
                {value}
              </Typography>
              <Typography sx={{ ...mono, fontSize: 10, color: MUTED2, mt: "2px" }}>{unit}</Typography>
            </Box>
          ))}
        </Box>
      )}

      <Typography sx={{ fontSize: 12, color: MUTED2, mb: 1.5, pl: "2px" }}>
        Page {currentPage} of {totalPages} — {totalCount} total transactions
      </Typography>

      <Box sx={{ bgcolor: "#0d0d14", border: `1px solid ${BORDER}`, borderRadius: "18px", overflow: "auto" }}>

        <Box sx={{
          display: "grid", gridTemplateColumns: COL, minWidth: 1100,
          px: "20px", py: "10px", gap: "12px",
          bgcolor: "rgba(255,255,255,0.02)",
          borderBottom: `1px solid rgba(255,255,255,0.05)`,
        }}>
          {["#", "User", "Price", "Extra", "Type", "Status", "Delivered", "Due", "Returned", ""].map((h) => (
            <Typography key={h} sx={{ ...mono, fontSize: 10, fontWeight: 600, color: MUTED2, letterSpacing: "0.8px", textTransform: "uppercase" }}>
              {h}
            </Typography>
          ))}
        </Box>

        {rows.length === 0 && !loading ? (
          <Box sx={{ py: 8, textAlign: "center" }}>
            <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: MUTED2, mb: 0.5 }}>
              No transactions yet
            </Typography>
            <Typography sx={{ fontSize: 12, color: MUTED2 }}>
              Hit "New Checkout" to record the first one.
            </Typography>
          </Box>
        ) : (
          rows.map((row, i) => (
            <Box
              key={row.id}
              sx={{
                display: "grid", gridTemplateColumns: COL, minWidth: 1100,
                px: "20px", py: "13px", gap: "12px",
                alignItems: "center",
                borderBottom: i < rows.length - 1 ? `1px solid rgba(255,255,255,0.04)` : "none",
                transition: "background .15s",
                "&:hover": { bgcolor: "rgba(255,255,255,0.02)" },
              }}
            >
              <Typography sx={{ ...mono, fontSize: 12, fontWeight: 700, color: MUTED2 }}>
                #{row.bill_id}
              </Typography>

              <Box sx={{ display: "flex", alignItems: "center", gap: "10px", minWidth: 0 }}>
                <Avatar name={row.user?.name ?? `User ${row.user_id}`} index={i} />
                <Box sx={{ minWidth: 0 }}>
                  <Typography sx={{ fontSize: 13, fontWeight: 600, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                    {row.user?.name ?? `User ${row.user_id}`}
                  </Typography>
                  <Typography sx={{ ...mono, fontSize: 10, color: MUTED }}>
                    ID · {row.user_id}
                  </Typography>
                </Box>
              </Box>

              <Typography sx={{ ...display, fontSize: 13, fontWeight: 700, color: GOLD }}>
                {fmt(row.price)} SYP
              </Typography>

              <Typography sx={{ ...mono, fontSize: 12, color: parseFloat(row.extra_price || 0) > 0 ? "#e06b5a" : MUTED2 }}>
                {fmt(row.extra_price)}
              </Typography>

              <Box><TypeChip type={row.type} /></Box>
              <Box><StatusChip status={row.status} /></Box>
              <DateCell value={row.delivered_at} />
              <DateCell value={row.due_date} />
              <DateCell value={row.returned_at} />
              <Box />
            </Box>
          ))
        )}

        {loading && rows.length > 0 && (
          <Box sx={{ py: 3, display: "flex", justifyContent: "center" }}>
            <CircularProgress size={24} sx={{ color: GOLD }} />
          </Box>
        )}
      </Box>

      <Pagination
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />

      <Dialog
        open={open}
        onClose={() => setOpen(false)}
        PaperProps={{
          sx: {
            borderRadius: "20px",
            minWidth: "400px", maxWidth: "440px",
            bgcolor: "#1a1a24",
            border: `1px solid rgba(201,168,76,0.18)`,
            boxShadow: "0 24px 60px rgba(0,0,0,0.5)",
          },
        }}
      >
        <DialogContent sx={{ p: "28px 26px 8px" }}>
          <Box sx={{ display: "flex", alignItems: "center", gap: 1.5, mb: 2.5 }}>
            <Box sx={{
              width: 36, height: 36, borderRadius: "10px",
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 16,
            }}>
              🔁
            </Box>
            <Box>
              <Typography sx={{ ...display, fontSize: 17, fontWeight: 600, color: TEXT }}>
                New Checkout
              </Typography>
              <Typography sx={{ fontSize: 12, color: MUTED }}>
                Fill in the details below
              </Typography>
            </Box>
          </Box>

          <TextField fullWidth label="Bill ID" margin="none" variant="filled" sx={inputSx}
            onChange={(e) => setFormData({ ...formData, bill_id: e.target.value })} />
          <TextField fullWidth label="Book ID" margin="none" variant="filled" sx={inputSx}
            onChange={(e) => setFormData({ ...formData, book_id: e.target.value })} />
          <TextField select fullWidth label="Type" margin="none" variant="filled"
            value={formData.type} sx={inputSx}
            onChange={(e) => setFormData({ ...formData, type: e.target.value })}
            SelectProps={{ MenuProps: { PaperProps: { sx: { bgcolor: "#1a1a24", color: TEXT } } } }}>
            <MenuItem value="borrow">📖 Borrow</MenuItem>
            <MenuItem value="buy">🛒 Buy</MenuItem>
          </TextField>
          <TextField fullWidth label="Days" type="number" margin="none" variant="filled"
            value={formData.days} sx={inputSx}
            onChange={(e) => setFormData({ ...formData, days: e.target.value })} />
          <TextField select fullWidth label="Payment Method" margin="none" variant="filled"
            value={formData.payment_method} sx={inputSx}
            onChange={(e) => setFormData({ ...formData, payment_method: e.target.value })}
            SelectProps={{ MenuProps: { PaperProps: { sx: { bgcolor: "#1a1a24", color: TEXT } } } }}>
            <MenuItem value="cash">💵 Cash</MenuItem>
            <MenuItem value="online">🌐 Online</MenuItem>
          </TextField>
        </DialogContent>

        <DialogActions sx={{ px: "26px", pb: "24px", pt: 2, gap: 1 }}>
          <Button onClick={() => setOpen(false)} sx={{
            borderRadius: "10px", textTransform: "none", fontWeight: 600,
            fontSize: 13.5, color: MUTED, border: `1px solid ${BORDER}`, px: 2.5,
            "&:hover": { bgcolor: "rgba(255,255,255,0.05)", color: TEXT },
          }}>
            Cancel
          </Button>
          <Button onClick={handleCheckout} variant="contained" disableElevation sx={{
            borderRadius: "10px", textTransform: "none",
            fontWeight: 700, fontSize: 13.5, px: 2.8, color: "#000",
            background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
            "&:hover": { background: `linear-gradient(135deg,#d4b05a,#9a6b20)`, boxShadow: "0 12px 28px rgba(201,168,76,0.25)" },
          }}>
            Confirm
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}