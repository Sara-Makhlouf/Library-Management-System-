

import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress, Collapse } from "@mui/material";
import { fetchBills, fetchBillDetails } from "../../Core/Redux/Thunks/BillThunk";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

const fmt = (val) =>
  parseFloat(val || 0).toLocaleString("en-US", { minimumFractionDigits: 2 });

const fmtDate = (iso) =>
  new Date(iso).toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });

const GRADIENTS = [
  "linear-gradient(135deg,#c9a84c,#8b5e1a)",
  "linear-gradient(135deg,#7f77dd,#4a43a0)",
  "linear-gradient(135deg,#1d9e75,#0f6b4f)",
  "linear-gradient(135deg,#97c459,#5f8e20)",
  "linear-gradient(135deg,#e06b5a,#a03322)",
];

const COL = "90px 2fr 1.2fr 1fr 1fr 1fr";

function Avatar({ name, index, size = 30, radius = "9px" }) {
  return (
    <Box sx={{
      width: size, height: size, minWidth: size, borderRadius: radius,
      background: GRADIENTS[index % GRADIENTS.length],
      display: "flex", alignItems: "center", justifyContent: "center",
      fontSize: size * 0.37, fontWeight: 700, color: "#fff",
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
        : { bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)", color: "#c9a84c" }),
    }}>
      {isOnline ? "🌐 Online" : "💵 Cash"}
    </Box>
  );
}

function BillDetailPanel({ bill }) {
  if (!bill) return null;
  const c = bill.customer;

  const summaryItems = [
    { label: "المجموع",       value: `${fmt(bill.total_price)} ل.س`, gold: true },
    { label: "الخصم",         value: `${fmt(bill.discount_amount)} ل.س` },
    { label: "رسوم التوصيل", value: `${fmt(bill.delivery_fee)} ل.س` },
    { label: "عدد الكتب",    value: bill.bill_details?.length ?? 0 },
  ];

  return (
    <Box sx={{ mx: "16px", mb: "14px" }}>
      <Box sx={{
        bgcolor: "rgba(255,255,255,0.02)",
        border: "1px solid rgba(255,255,255,0.06)",
        borderRadius: "12px", overflow: "hidden",
      }}>
        {/* Summary bar */}
        <Box sx={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", bgcolor: "rgba(201,168,76,0.03)", borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
          {summaryItems.map(({ label, value, gold }) => (
            <Box key={label} sx={{ px: "16px", py: "12px", borderRight: "1px solid rgba(255,255,255,0.04)", "&:last-child": { borderRight: "none" } }}>
              <Typography sx={{ fontSize: 10, color: "rgba(255,255,255,0.3)", mb: "4px" }}>{label}</Typography>
              <Typography sx={{ fontSize: 14, fontWeight: 700, color: gold ? "#c9a84c" : "#fff" }}>{value}</Typography>
            </Box>
          ))}
        </Box>

        {/* Customer */}
        <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", px: "16px", py: "12px", borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
          <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
            <Avatar name={c.name} index={0} size={36} radius="10px" />
            <Box>
              <Typography sx={{ fontSize: 12.5, fontWeight: 600, color: "#fff", mb: "2px" }}>{c.name}</Typography>
              <Typography sx={{ fontSize: 11, color: "rgba(255,255,255,0.3)" }}>
                📞 {c.phone} · 📍 {c.address?.replace(/\n/g, ", ")}
              </Typography>
            </Box>
          </Box>
          <Box sx={{
            display: "inline-flex", alignItems: "center", gap: "3px",
            px: "8px", py: "2px", borderRadius: "5px",
            bgcolor: "rgba(201,168,76,0.08)", fontSize: 10, fontWeight: 600, color: "rgba(201,168,76,0.7)",
          }}>
            ⭐ {c.points_balance} pts
          </Box>
        </Box>

        {/* Books */}
        <Typography sx={{ fontSize: 10, fontWeight: 600, color: "rgba(255,255,255,0.25)", letterSpacing: "0.8px", textTransform: "uppercase", px: "16px", pt: "10px", pb: "4px" }}>
          الكتب المشتراة
        </Typography>

        {bill.bill_details?.map((item) => (
          <Box key={item.id} sx={{
            display: "flex", alignItems: "center", gap: "12px",
            px: "16px", py: "10px", borderTop: "1px solid rgba(255,255,255,0.04)",
          }}>
            <Box sx={{ width: 34, height: 44, borderRadius: "6px", bgcolor: "rgba(255,255,255,0.06)", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 16, flexShrink: 0 }}>
              📚
            </Box>
            <Box sx={{ flex: 1, minWidth: 0 }}>
              <Box sx={{ display: "flex", alignItems: "center", gap: "6px", mb: "3px" }}>
                <Typography sx={{ fontSize: 12.5, fontWeight: 600, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 320 }}>
                  {item.book.title}
                </Typography>
                {item.book.is_digital && (
                  <Box sx={{ display: "inline-flex", px: "6px", py: "1px", borderRadius: "4px", bgcolor: "rgba(127,119,221,0.1)", fontSize: 10, color: "#7f77dd", fontWeight: 600, flexShrink: 0 }}>
                    Digital
                  </Box>
                )}
              </Box>
              <Typography sx={{ fontSize: 11, color: "rgba(255,255,255,0.3)" }}>
                ISBN: {item.book.ISBN} · {item.book.total_pages} صفحة · الكمية: {item.quantity}
              </Typography>
            </Box>
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "#c9a84c", whiteSpace: "nowrap", ml: "auto" }}>
              {fmt(item.unit_price)} ل.س
            </Typography>
          </Box>
        ))}
      </Box>
    </Box>
  );
}

export default function BillsPage() {
  const dispatch = useDispatch();

  const { list, currentBill, loading } = useSelector((state) => state.Bill);

  const [expandedId, setExpandedId] = useState(null);

  useEffect(() => { dispatch(fetchBills()); }, [dispatch]);

  const handleToggle = (billId) => {
    if (expandedId === billId) { setExpandedId(null); return; }
    setExpandedId(billId);
    dispatch(fetchBillDetails(billId));
  };

  const bills = Array.isArray(list) ? list : [];

  if (loading && bills.length === 0) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: "#0a0a0f", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <CircularProgress sx={{ color: "#c9a84c" }} />
      </Box>
    );
  }

  return (
    <Box sx={{
      minHeight: "100vh", bgcolor: "#0a0a0f",
      p: { xs: 2, md: "24px 28px" },
      ml: { xs: 0 },
      fontFamily: "Inter, sans-serif",
    }}>
      <Box sx={{ mb: 3 }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5, mb: 0.5 }}>
          <Typography sx={{ fontSize: 22, fontWeight: 800, color: "#fff", letterSpacing: -0.5 }}>Bills</Typography>
          {bills.length > 0 && (
            <Box sx={{ px: "10px", py: "3px", borderRadius: "20px", bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)", fontSize: 11, fontWeight: 600, color: "#c9a84c" }}>
              {bills.length} bill
            </Box>
          )}
        </Box>
        <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>Tab To view the bills</Typography>
      </Box>

      <Box sx={{ bgcolor: "#0d0d14", border: "1px solid rgba(255,255,255,0.06)", borderRadius: "16px", overflow: "hidden" }}>
        {/* Head */}
        <Box sx={{ display: "grid", gridTemplateColumns: COL, px: "20px", py: "10px", bgcolor: "rgba(255,255,255,0.02)", borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
          {["#", "customer", "price", "status", "payment", "date"].map((h) => (
            <Typography key={h} sx={{ fontSize: 10, fontWeight: 600, color: "rgba(255,255,255,0.25)", letterSpacing: "0.8px", textTransform: "uppercase" }}>
              {h}
            </Typography>
          ))}
        </Box>

        {bills.map((bill, i) => {
          const isOpen = expandedId === bill.id;
          const isThisLoading = isOpen && loading;

          return (
            <Box key={bill.id} sx={{ borderBottom: i < bills.length - 1 ? "1px solid rgba(255,255,255,0.04)" : "none" }}>
              <Box
                onClick={() => handleToggle(bill.id)}
                sx={{
                  display: "grid", gridTemplateColumns: COL,
                  px: "20px", py: "13px", alignItems: "center", cursor: "pointer",
                  bgcolor: isOpen ? "rgba(201,168,76,0.03)" : "transparent",
                  transition: "background .15s",
                  "&:hover": { bgcolor: isOpen ? "rgba(201,168,76,0.04)" : "rgba(255,255,255,0.02)" },
                }}
              >
                <Box sx={{ display: "flex", alignItems: "center", gap: "6px" }}>
                  <Typography sx={{ fontSize: 12, fontWeight: 700, color: "rgba(255,255,255,0.3)" }}>#{bill.id}</Typography>
                  <Box sx={{ fontSize: 11, color: "rgba(255,255,255,0.2)", transition: "transform .25s", transform: isOpen ? "rotate(180deg)" : "none" }}>▾</Box>
                </Box>

                <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
                  <Avatar name={bill.customer.name} index={i} />
                  <Box sx={{ minWidth: 0 }}>
                    <Typography sx={{ fontSize: 13, fontWeight: 600, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>
                      {bill.customer.name}
                    </Typography>
                    <Typography sx={{ fontSize: 11, color: "rgba(255,255,255,0.3)" }}>{bill.customer.phone}</Typography>
                  </Box>
                </Box>

                <Typography sx={{ fontSize: 13, fontWeight: 700, color: "#fff" }}>{fmt(bill.total_price)}S.P</Typography>
                <Box><StatusChip status={bill.status} /></Box>
                <Box><PaymentChip method={bill.payment_method} /></Box>
                <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.35)" }}>{fmtDate(bill.created_at)}</Typography>
              </Box>

              <Collapse in={isOpen} unmountOnExit>
                {isThisLoading ? (
                  <Box sx={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 1, py: 3 }}>
                    <CircularProgress size={14} sx={{ color: "#c9a84c" }} />
                    <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>Loading The Details ...  </Typography>
                  </Box>
                ) : (
                  <BillDetailPanel bill={currentBill} />
                )}
              </Collapse>
            </Box>
          );
        })}

        {bills.length === 0 && !loading && (
          <Box sx={{ py: 8, textAlign: "center" }}>
            <Typography sx={{ fontSize: 13, color: "rgba(255,255,255,0.2)" }}> No bills !</Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}