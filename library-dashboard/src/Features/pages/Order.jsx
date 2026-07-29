import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress } from "@mui/material";
import toast from "react-hot-toast";
import { fetchDeliveryOrders, updateDeliveryStatus } from "../../Core/Redux/Thunks/OrderThunk";
import {STATUSES,FILTERS,COL,Avatar,fmt,StatusChip,StatusStepper} from "../Utils/orderData";
import { GOLD, GOLD_DARK, INK, PAGE_BG, CARD_BG, inkA, goldA } from "../../Core/Constants/ColorsUse";


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


const STATUS_ACCENT = {
  pending:    "#d59a1f",
  processing: "#2f9fd6",
  shipped:    "#7f77dd",
  delivered:  "#3fb873",
  cancelled:  "#e0655f",
};

function getAccent(status) {
  return STATUS_ACCENT[status] || goldA(0.18);
}

export default function DeliveryPage() {
  const dispatch = useDispatch();
  const { list, loading, updateLoading } = useSelector((state) => state.delivery);
  const [activeFilter, setActiveFilter] = useState("all");

  useEffect(() => { injectFonts(); }, []);
  useEffect(() => { dispatch(fetchDeliveryOrders()); }, [dispatch]);

  const handleFilterChange = (key) => {
    setActiveFilter(key);
    dispatch(fetchDeliveryOrders(key === "all" ? null : key));
  };

  const handleUpdate = async (id, delivery_status) => {
    try {
      await dispatch(updateDeliveryStatus({ id, delivery_status })).unwrap();
      toast.success(`Updated to: ${STATUSES[delivery_status].label}`);
    } catch (err) {
      toast.error(err?.message ?? "Failed to update status");
    }
  };

  const filtered = activeFilter === "all"
    ? list
    : list.filter((b) => b.delivery_status === activeFilter);

  const countFor = (key) =>
    key === "all" ? list.length : list.filter((b) => b.delivery_status === key).length;

  if (loading && list.length === 0) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: PAGE_BG, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <CircularProgress sx={{ color: GOLD }} />
      </Box>
    );
  }

  return (
    <Box sx={{
      minHeight: "100vh", bgcolor: PAGE_BG,
      p: { xs: 2, md: "24px 28px" },
      ml: { xs: 0 },
      fontFamily: "Inter, sans-serif",
    }}>
      <Box sx={{ mb: 3 }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5, mb: 0.5 }}>
          <Typography sx={{ ...display, fontSize: 23, fontWeight: 600, color: INK, letterSpacing: -0.4 }}>
            Delivery Orders
          </Typography>
          <Box sx={{
            ...mono,
            px: "10px", py: "3px", borderRadius: "20px",
            bgcolor: goldA(0.1), border: `1px solid ${goldA(0.24)}`,
            fontSize: 11, fontWeight: 600, color: GOLD_DARK,
          }}>
            {filtered.length} {filtered.length === 1 ? "order" : "orders"}
          </Box>
        </Box>
        <Typography sx={{ fontSize: 12, color: inkA(0.42) }}>
          Manage and trace the status of orders
        </Typography>
      </Box>

      <Box sx={{ display: "flex", gap: 1, mb: 2.5, flexWrap: "wrap" }}>
        {FILTERS.map((f) => (
          <Box
            key={f.key}
            onClick={() => handleFilterChange(f.key)}
            sx={{
              display: "flex", alignItems: "center", gap: "6px",
              px: "14px", py: "6px", borderRadius: "8px",
              fontSize: 12, fontWeight: 600, cursor: "pointer",
              transition: "all .2s",
              ...(activeFilter === f.key
                ? { color: GOLD_DARK, bgcolor: goldA(0.1), border: `1px solid ${goldA(0.32)}` }
                : { color: inkA(0.45), bgcolor: inkA(0.03), border: `1px solid ${goldA(0.14)}`, "&:hover": { color: INK, bgcolor: goldA(0.07) } }),
            }}
          >
            {f.label}
            <Box
              component="span"
              sx={{
                ...mono,
                fontSize: 10.5,
                color: activeFilter === f.key ? GOLD_DARK : inkA(0.35),
                opacity: 0.85,
              }}
            >
              {countFor(f.key)}
            </Box>
          </Box>
        ))}
      </Box>

      <Box sx={{ bgcolor: CARD_BG, border: `1px solid ${goldA(0.16)}`, borderRadius: "22px", overflow: "hidden", boxShadow: "0 2px 14px rgba(201,168,76,.08)" }}>
        <Box sx={{ display: "grid", gridTemplateColumns: COL, px: "20px", py: "10px", bgcolor: goldA(0.05), borderBottom: `1px solid ${goldA(0.14)}` }}>
          {["Order", "Customer", "Price", "Status", "Update status"].map((h) => (
            <Typography key={h} sx={{ fontSize: 10, fontWeight: 600, color: inkA(0.42), letterSpacing: "0.8px", textTransform: "uppercase" }}>
              {h}
            </Typography>
          ))}
        </Box>

        {filtered.length > 0 ? filtered.map((bill, i) => (
          <Box
            key={bill.id}
            sx={{
              display: "grid", gridTemplateColumns: COL,
              px: "20px", py: "14px", alignItems: "center",
              position: "relative",
              borderBottom: i < filtered.length - 1 ? `1px solid ${goldA(0.1)}` : "none",
              transition: "background .15s",
              "&:hover": { bgcolor: goldA(0.05) },
              "&::before": {
                content: '""',
                position: "absolute",
                left: 0, top: "12%", bottom: "12%",
                width: 3, borderRadius: "0 3px 3px 0",
                bgcolor: getAccent(bill.delivery_status),
              },
            }}
          >
            <Typography sx={{ ...mono, fontSize: 12, fontWeight: 600, color: inkA(0.4) }}>
              #{bill.id}
            </Typography>

            <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <Avatar name={bill.customer?.name ?? "?"} index={i} />
              <Box sx={{ minWidth: 0 }}>
                <Typography sx={{ fontSize: 13, fontWeight: 600, color: INK, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>
                  {bill.customer?.name}
                </Typography>
                {bill.delivery_address && (
                  <Typography sx={{ fontSize: 11, color: inkA(0.42), whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 200 }}>
                    {bill.delivery_address}
                  </Typography>
                )}
              </Box>
            </Box>

            <Typography sx={{ ...mono, fontSize: 13, fontWeight: 700, color: GOLD_DARK }}>
              {fmt(bill.total_price)} <Box component="span" sx={{ fontFamily: "Inter, sans-serif", fontSize: 11, color: inkA(0.45) }}>ل.س</Box>
            </Typography>

            <Box>
              <StatusChip status={bill.delivery_status} />
            </Box>

            <Box>
              <StatusStepper
                bill={bill}
                onUpdate={handleUpdate}
                isUpdating={updateLoading === bill.id}
              />
            </Box>
          </Box>
        )) : (
          <Box sx={{ py: 8, textAlign: "center" }}>
            <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: inkA(0.4), mb: 0.5 }}>
              Nothing here yet
            </Typography>
            <Typography sx={{ fontSize: 12, color: inkA(0.28) }}>
              {activeFilter === "all" ? "No delivery orders so far" : "No orders match this filter"}
            </Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}