import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress } from "@mui/material";
import toast from "react-hot-toast";
import { fetchDeliveryOrders, updateDeliveryStatus } from "../../Core/Redux/Thunks/OrderThunk";
import {STATUSES,FILTERS,COL,Avatar,fmt,StatusChip,StatusStepper} from "../Utils/orderData";


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
  pending:    "#fbbf24",
  processing: "#38bdf8",
  shipped:    "#7f77dd",
  delivered:  "#4ade80",
  cancelled:  "#f87171",
};

function getAccent(status) {
  return STATUS_ACCENT[status] || "rgba(255,255,255,0.12)";
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
          <Typography sx={{ ...display, fontSize: 23, fontWeight: 600, color: "#fff", letterSpacing: -0.4 }}>
            Delivery Orders
          </Typography>
          <Box sx={{
            ...mono,
            px: "10px", py: "3px", borderRadius: "20px",
            bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
            fontSize: 11, fontWeight: 600, color: "#c9a84c",
          }}>
            {filtered.length} {filtered.length === 1 ? "order" : "orders"}
          </Box>
        </Box>
        <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
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
                ? { color: "#c9a84c", bgcolor: "rgba(201,168,76,0.07)", border: "1px solid rgba(201,168,76,0.3)" }
                : { color: "rgba(255,255,255,0.4)", bgcolor: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.08)", "&:hover": { color: "#fff", bgcolor: "rgba(255,255,255,0.06)" } }),
            }}
          >
            {f.label}
            <Box
              component="span"
              sx={{
                ...mono,
                fontSize: 10.5,
                color: activeFilter === f.key ? "#c9a84c" : "rgba(255,255,255,0.3)",
                opacity: 0.85,
              }}
            >
              {countFor(f.key)}
            </Box>
          </Box>
        ))}
      </Box>

      <Box sx={{ bgcolor: "#0d0d14", border: "1px solid rgba(255,255,255,0.06)", borderRadius: "16px", overflow: "hidden" }}>
        <Box sx={{ display: "grid", gridTemplateColumns: COL, px: "20px", py: "10px", bgcolor: "rgba(255,255,255,0.02)", borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
          {["Order", "Customer", "Price", "Status", "Update status"].map((h) => (
            <Typography key={h} sx={{ fontSize: 10, fontWeight: 600, color: "rgba(255,255,255,0.25)", letterSpacing: "0.8px", textTransform: "uppercase" }}>
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
              borderBottom: i < filtered.length - 1 ? "1px solid rgba(255,255,255,0.04)" : "none",
              transition: "background .15s",
              "&:hover": { bgcolor: "rgba(255,255,255,0.02)" },
              "&::before": {
                content: '""',
                position: "absolute",
                left: 0, top: "12%", bottom: "12%",
                width: 3, borderRadius: "0 3px 3px 0",
                bgcolor: getAccent(bill.delivery_status),
              },
            }}
          >
            <Typography sx={{ ...mono, fontSize: 12, fontWeight: 600, color: "rgba(255,255,255,0.3)" }}>
              #{bill.id}
            </Typography>

            <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <Avatar name={bill.customer?.name ?? "?"} index={i} />
              <Box sx={{ minWidth: 0 }}>
                <Typography sx={{ fontSize: 13, fontWeight: 600, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>
                  {bill.customer?.name}
                </Typography>
                {bill.delivery_address && (
                  <Typography sx={{ fontSize: 11, color: "rgba(255,255,255,0.3)", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 200 }}>
                    {bill.delivery_address}
                  </Typography>
                )}
              </Box>
            </Box>

            <Typography sx={{ ...mono, fontSize: 13, fontWeight: 600, color: "#fff" }}>
              {fmt(bill.total_price)} <Box component="span" sx={{ fontFamily: "Inter, sans-serif", fontSize: 11, color: "rgba(255,255,255,0.4)" }}>ل.س</Box>
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
            <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: "rgba(255,255,255,0.35)", mb: 0.5 }}>
              Nothing here yet
            </Typography>
            <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.2)" }}>
              {activeFilter === "all" ? "No delivery orders so far" : "No orders match this filter"}
            </Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}