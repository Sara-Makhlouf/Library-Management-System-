import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress, Collapse } from "@mui/material";
import { fetchBills, fetchBillDetails } from "../../Core/Redux/Thunks/BillThunk";

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

const COL = "90px 2fr 1.2fr 1fr 1fr 1fr";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

const fmt = (val) =>
  parseFloat(val || 0).toLocaleString("en-US", { minimumFractionDigits: 2 });

const fmtDate = (iso) =>
  new Date(iso).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });

function Avatar({ name, index, size = 30, radius = "9px" }) {
  return (
    <Box sx={{
      width: size, height: size, minWidth: size, borderRadius: radius,
      background: GRADIENTS[index % GRADIENTS.length],
      display: "flex", alignItems: "center", justifyContent: "center",
      fontSize: size * 0.37, fontWeight: 700, color: TEXT,
    }}>
      {initials(name)}
    </Box>
  );
}

function StatusChip({ status }) {
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center", gap: "4px",
      px: "8px", py: "3px", borderRadius: "6px", fontSize: 11, fontWeight: 600,
      bgcolor: "rgba(29,158,117,0.1)", border: "1px solid rgba(29,158,117,0.2)", color: "#1d9e75",
    }}>
      <Box sx={{ width: 5, height: 5, borderRadius: "50%", bgcolor: "currentColor" }} />
      {status}
    </Box>
  );
}

function PaymentChip({ method }) {
  const isOnline = method === "online";
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center", gap: "4px",
      px: "8px", py: "3px", borderRadius: "6px", fontSize: 11, fontWeight: 600,
      ...(isOnline
        ? { bgcolor: "rgba(127,119,221,0.1)", border: "1px solid rgba(127,119,221,0.2)", color: "#7f77dd" }
        : { bgcolor: "rgba(201,168,76,0.1)",  border: "1px solid rgba(201,168,76,0.2)",  color: GOLD }),
    }}>
      {isOnline ? "🌐 Online" : "💵 Cash"}
    </Box>
  );
}

function Pagination({ currentPage, totalPages, onPageChange }) {
  if (totalPages <= 1) return null;
  const pages = Array.from({ length: totalPages }, (_, i) => i + 1);
  const btnBase = {
    display: "flex", alignItems: "center", justifyContent: "center",
    borderRadius: "10px", userSelect: "none", fontSize: 13,
    fontWeight: 700, transition: "all .15s",
  };
  return (
    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 1, mt: 2.5 }}>
      <Box
        onClick={() => currentPage > 1 && onPageChange(currentPage - 1)}
        sx={{
          ...btnBase, px: "14px", height: 36, cursor: currentPage === 1 ? "not-allowed" : "pointer",
          bgcolor: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`,
          color: currentPage === 1 ? MUTED2 : MUTED,
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
            ...btnBase, width: 36, height: 36, cursor: "pointer",
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
          ...btnBase, px: "14px", height: 36,
          cursor: currentPage === totalPages ? "not-allowed" : "pointer",
          bgcolor: "rgba(255,255,255,0.04)", border: `1px solid ${BORDER}`,
          color: currentPage === totalPages ? MUTED2 : MUTED,
          "&:hover": currentPage < totalPages ? { bgcolor: "rgba(255,255,255,0.08)", color: TEXT } : {},
        }}
      >
        Next →
      </Box>
    </Box>
  );
}

function BillDetailPanel({ bill }) {
  if (!bill) return null;
  const c = bill.customer;

  const summaryItems = [
    { label: "Total",    value: `${fmt(bill.total_price)} SYP`,    gold: true },
    { label: "Discount", value: `${fmt(bill.discount_amount)} SYP` },
    { label: "Delivery", value: `${fmt(bill.delivery_fee)} SYP`    },
    { label: "Books",    value: bill.bill_details?.length ?? 0      },
  ];

  return (
    <Box sx={{ mx: "16px", mb: "14px" }}>
      <Box sx={{
        bgcolor: "rgba(255,255,255,0.02)",
        border: `1px solid ${BORDER}`,
        borderRadius: "12px", overflow: "hidden",
      }}>
        <Box sx={{
          display: "grid", gridTemplateColumns: "repeat(4,1fr)",
          bgcolor: "rgba(201,168,76,0.03)",
          borderBottom: `1px solid rgba(255,255,255,0.05)`,
        }}>
          {summaryItems.map(({ label, value, gold }) => (
            <Box key={label} sx={{
              px: "16px", py: "12px",
              borderRight: `1px solid rgba(255,255,255,0.04)`,
              "&:last-child": { borderRight: "none" },
            }}>
              <Typography sx={{ ...mono, fontSize: 10, color: MUTED, mb: "4px" }}>{label}</Typography>
              <Typography sx={{ ...display, fontSize: 14, fontWeight: 700, color: gold ? GOLD : TEXT }}>{value}</Typography>
            </Box>
          ))}
        </Box>

        <Box sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          px: "16px", py: "12px",
          borderBottom: `1px solid rgba(255,255,255,0.05)`,
        }}>
          <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
            <Avatar name={c.name} index={0} size={36} radius="10px" />
            <Box>
              <Typography sx={{ fontSize: 12.5, fontWeight: 600, color: TEXT, mb: "2px" }}>{c.name}</Typography>
              <Typography sx={{ ...mono, fontSize: 11, color: MUTED }}>
                📞 {c.phone} · 📍 {c.address?.replace(/\n/g, ", ")}
              </Typography>
            </Box>
          </Box>
          <Box sx={{
            ...mono,
            display: "inline-flex", alignItems: "center", gap: "3px",
            px: "8px", py: "2px", borderRadius: "5px",
            bgcolor: "rgba(201,168,76,0.08)", fontSize: 10, fontWeight: 600,
            color: "rgba(201,168,76,0.7)",
          }}>
            ⭐ {c.points_balance} pts
          </Box>
        </Box>

        <Typography sx={{
          ...mono, fontSize: 10, fontWeight: 600, color: MUTED2,
          letterSpacing: "0.8px", textTransform: "uppercase",
          px: "16px", pt: "10px", pb: "4px",
        }}>
          Purchased Books
        </Typography>

        {bill.bill_details?.map((item) => (
          <Box key={item.id} sx={{
            display: "flex", alignItems: "center", gap: "12px",
            px: "16px", py: "10px",
            borderTop: `1px solid rgba(255,255,255,0.04)`,
          }}>
            <Box sx={{
              width: 34, height: 44, borderRadius: "6px",
              bgcolor: "rgba(255,255,255,0.06)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 16, flexShrink: 0,
            }}>
              📚
            </Box>
            <Box sx={{ flex: 1, minWidth: 0 }}>
              <Box sx={{ display: "flex", alignItems: "center", gap: "6px", mb: "3px" }}>
                <Typography sx={{
                  ...display, fontSize: 12.5, fontWeight: 600, color: TEXT,
                  whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 320,
                }}>
                  {item.book.title}
                </Typography>
                {item.book.is_digital && (
                  <Box sx={{
                    display: "inline-flex", px: "6px", py: "1px", borderRadius: "4px",
                    bgcolor: "rgba(127,119,221,0.1)", fontSize: 10, color: "#7f77dd",
                    fontWeight: 600, flexShrink: 0,
                  }}>
                    Digital
                  </Box>
                )}
              </Box>
              <Typography sx={{ ...mono, fontSize: 11, color: MUTED }}>
                ISBN: {item.book.ISBN} · {item.book.total_pages} pages · Qty: {item.quantity}
              </Typography>
            </Box>
            <Typography sx={{ ...display, fontSize: 13, fontWeight: 700, color: GOLD, whiteSpace: "nowrap", ml: "auto" }}>
              {fmt(item.unit_price)} ل.س
            </Typography>
          </Box>
        ))}
      </Box>
    </Box>
  );
}

function StatCard({ label, value, unit, gold = false }) {
  return (
    <Box sx={{ bgcolor: SURFACE, border: `1px solid ${BORDER}`, borderRadius: "16px", p: "18px 20px" }}>
      <Typography sx={{ ...mono, fontSize: 10, fontWeight: 600, letterSpacing: "0.7px", color: MUTED2, textTransform: "uppercase", mb: "8px" }}>
        {label}
      </Typography>
      <Typography sx={{ ...display, fontSize: 26, fontWeight: 600, color: gold ? GOLD : TEXT, letterSpacing: "-0.5px" }}>
        {value}
      </Typography>
      {unit && <Typography sx={{ ...mono, fontSize: 10, color: MUTED2, mt: "2px" }}>{unit}</Typography>}
    </Box>
  );
}


export default function BillsPage() {
  const dispatch = useDispatch();
  const { list, pagination, currentBill, loading, detailLoading } = useSelector((state) => state.Bill);

  const [expandedId,  setExpandedId]  = useState(null);
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => { injectFonts(); }, []);

  useEffect(() => {
    dispatch(fetchBills({ page: currentPage }));
    setExpandedId(null); 
  }, [dispatch, currentPage]);

  const handleToggle = (billId) => {
    if (expandedId === billId) { setExpandedId(null); return; }
    setExpandedId(billId);
    dispatch(fetchBillDetails(billId));
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const bills      = Array.isArray(list) ? list : [];
  const totalPages = pagination?.lastPage ?? 1;
  const totalCount = pagination?.total    ?? bills.length;

  const totalRevenue = bills.reduce((s, b) => s + parseFloat(b.total_price || 0), 0);
  const avgBill      = bills.length ? totalRevenue / bills.length : 0;

  if (loading && bills.length === 0) {
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
          }}>
            <Typography sx={{ fontSize: 14, lineHeight: 1 }}>🧾</Typography>
          </Box>
          <Typography sx={{ ...display, fontWeight: 600, fontSize: 16, color: TEXT, letterSpacing: -0.2 }}>
            Bills
          </Typography>
        </Box>

        <Box sx={{
          ...mono, px: "12px", py: "5px", borderRadius: "8px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11.5, fontWeight: 600, color: GOLD,
        }}>
          {totalCount} {totalCount === 1 ? "bill" : "bills"}
        </Box>
      </Box>

      {bills.length > 0 && (
        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "repeat(3,1fr)" }, gap: 2, mb: 2.5 }}>
          <StatCard label="Total Revenue" value={fmt(totalRevenue)} unit="ل.س" gold />
          <StatCard label="Total Bills"   value={totalCount}        unit="all pages" />
          <StatCard label="Avg. Bill"     value={fmt(avgBill)}      unit="ل.س this page" />
        </Box>
      )}

      <Typography sx={{ fontSize: 12, color: MUTED2, mb: 1.5, pl: "2px" }}>
        Page {currentPage} of {totalPages} — {totalCount} total · Tap any row to view details
      </Typography>

      <Box sx={{ bgcolor: "#0d0d14", border: `1px solid ${BORDER}`, borderRadius: "18px", overflow: "hidden" }}>

        <Box sx={{
          display: "grid", gridTemplateColumns: COL,
          px: "20px", py: "10px", gap: "12px",
          bgcolor: "rgba(255,255,255,0.02)",
          borderBottom: `1px solid rgba(255,255,255,0.05)`,
        }}>
          {["#", "Customer", "Total", "Status", "Payment", "Date"].map((h) => (
            <Typography key={h} sx={{ ...mono, fontSize: 10, fontWeight: 600, color: MUTED2, letterSpacing: "0.8px", textTransform: "uppercase" }}>
              {h}
            </Typography>
          ))}
        </Box>

        {bills.length === 0 && !loading ? (
          <Box sx={{ py: 8, textAlign: "center" }}>
            <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: MUTED2, mb: 0.5 }}>No bills yet</Typography>
            <Typography sx={{ fontSize: 12, color: MUTED2 }}>No bills have been recorded.</Typography>
          </Box>
        ) : (
          bills.map((bill, i) => {
            const isOpen        = expandedId === bill.id;
            const isThisLoading = isOpen && detailLoading;

            return (
              <Box key={bill.id} sx={{ borderBottom: i < bills.length - 1 ? `1px solid rgba(255,255,255,0.04)` : "none" }}>

                <Box
                  onClick={() => handleToggle(bill.id)}
                  sx={{
                    display: "grid", gridTemplateColumns: COL,
                    px: "20px", py: "13px", gap: "12px",
                    alignItems: "center", cursor: "pointer",
                    bgcolor: isOpen ? "rgba(201,168,76,0.03)" : "transparent",
                    transition: "background .15s",
                    "&:hover": { bgcolor: isOpen ? "rgba(201,168,76,0.04)" : "rgba(255,255,255,0.02)" },
                  }}
                >
                  <Box sx={{ display: "flex", alignItems: "center", gap: "6px" }}>
                    <Typography sx={{ ...mono, fontSize: 12, fontWeight: 700, color: MUTED2 }}>#{bill.id}</Typography>
                    <Box sx={{
                      fontSize: 11, color: isOpen ? GOLD : MUTED2,
                      transition: "transform .25s",
                      transform: isOpen ? "rotate(180deg)" : "none",
                    }}>▾</Box>
                  </Box>

                  <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
                    <Avatar name={bill.customer.name} index={i} />
                    <Box sx={{ minWidth: 0 }}>
                      <Typography sx={{ fontSize: 13, fontWeight: 600, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>
                        {bill.customer.name}
                      </Typography>
                      <Typography sx={{ ...mono, fontSize: 11, color: MUTED }}>{bill.customer.phone}</Typography>
                    </Box>
                  </Box>

                  <Typography sx={{ ...display, fontSize: 13, fontWeight: 700, color: TEXT }}>
                    {fmt(bill.total_price)} ل.س
                  </Typography>

                  <Box><StatusChip status={bill.status} /></Box>
                  <Box><PaymentChip method={bill.payment_method} /></Box>

                  <Typography sx={{ fontSize: 12, color: MUTED }}>📆 {fmtDate(bill.created_at)} </Typography>
                </Box>

                <Collapse in={isOpen} unmountOnExit>
                  {isThisLoading ? (
                    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 1, py: 3 }}>
                      <CircularProgress size={14} sx={{ color: GOLD }} />
                      <Typography sx={{ fontSize: 12, color: MUTED }}>Loading details...</Typography>
                    </Box>
                  ) : (
                    <BillDetailPanel bill={currentBill} />
                  )}
                </Collapse>
              </Box>
            );
          })
        )}

        {loading && bills.length > 0 && (
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
    </Box>
  );
}