import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress } from "@mui/material";
import toast from "react-hot-toast";
import { fetchDeliveryOrders, updateDeliveryStatus } from "../../Core/Redux/Thunks/OrderThunk";

const STATUSES = {
  pending:          { label: "Waiting",   color: "#fbbf24", bg: "rgba(251,191,36,0.1)",  border: "rgba(251,191,36,0.25)"  },
  preparing:        { label: "In progress ",   color: "#818cf8", bg: "rgba(99,102,241,0.1)",  border: "rgba(99,102,241,0.25)"  },
  out_for_delivery: { label: " Out to delivery ",    color: "#c9a84c", bg: "rgba(201,168,76,0.1)",  border: "rgba(201,168,76,0.25)"  },
  delivered:        { label: "Delivered! ",      color: "#1d9e75", bg: "rgba(29,158,117,0.1)", border: "rgba(29,158,117,0.25)" },
};

const STEPS = [
  { key: "pending",          label: "pending" },
  { key: "preparing",        label: "preparing"  },
  { key: "out_for_delivery", label: "خرج"    },
  { key: "delivered",        label: "delivered"  },
];

const FILTERS = [
  { key: "all",              label: "all"           },
  { key: "pending",          label: "pending ⏳  " },
  { key: "preparing",        label: "preparing 📦  " },
  { key: "out_for_delivery", label: "out_for_delivery 🚚  "  },
  { key: "delivered",        label: " delivered ✅ "   },
];

const GRADIENTS = [
  "linear-gradient(135deg,#c9a84c,#8b5e1a)",
  "linear-gradient(135deg,#7f77dd,#4a43a0)",
  "linear-gradient(135deg,#1d9e75,#0f6b4f)",
  "linear-gradient(135deg,#97c459,#5f8e20)",
  "linear-gradient(135deg,#e06b5a,#a03322)",
];

const COL = "70px 2fr 1.2fr 1.4fr 1fr";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

const fmt = (val) =>
  parseFloat(val || 0).toLocaleString("en-US", { minimumFractionDigits: 2 });

function Avatar({ name, index }) {
  return (
    <Box sx={{
      width: 32, height: 32, minWidth: 32, borderRadius: "9px",
      background: GRADIENTS[index % GRADIENTS.length],
      display: "flex", alignItems: "center", justifyContent: "center",
      fontSize: 12, fontWeight: 700, color: "#fff",
    }}>
      {initials(name)}
    </Box>
  );
}


function StatusChip({ status }) {
  const s = STATUSES[status] ?? STATUSES.pending;
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center", gap: "5px",
      px: "10px", py: "4px", borderRadius: "20px", fontSize: 11, fontWeight: 600,
      bgcolor: s.bg, border: `1px solid ${s.border}`, color: s.color,
    }}>
      <Box sx={{ width: 6, height: 6, borderRadius: "50%", bgcolor: s.color, flexShrink: 0 }} />
      {s.label}
    </Box>
  );
}

function StatusStepper({ bill, onUpdate, isUpdating }) {
  const currentIdx = STEPS.findIndex((s) => s.key === bill.delivery_status);

  return (
    <Box sx={{ display: "flex", alignItems: "center" }}>
      {STEPS.map((step, i) => {
        const isActive = bill.delivery_status === step.key;
        const isDone   = i < currentIdx;
        const s        = STATUSES[step.key];

        return (
          <Box
            key={step.key}
            onClick={() => !isUpdating && onUpdate(bill.id, step.key)}
            sx={{
              px: "10px", py: "5px", fontSize: 11, fontWeight: 600,
              cursor: isUpdating ? "wait" : "pointer",
              border: "1px solid",
              borderLeft: i > 0 ? "none" : "1px solid",
              borderRadius: i === 0 ? "8px 0 0 8px" : i === STEPS.length - 1 ? "0 8px 8px 0" : "0",
              transition: "all .2s",
              ...(isActive
                ? { color: s.color, bgcolor: s.bg, borderColor: s.border }
                : isDone
                ? { color: "rgba(255,255,255,0.4)", bgcolor: "rgba(255,255,255,0.04)", borderColor: "rgba(255,255,255,0.1)" }
                : { color: "rgba(255,255,255,0.25)", bgcolor: "rgba(255,255,255,0.02)", borderColor: "rgba(255,255,255,0.07)" }),
              "&:hover": !isUpdating && !isActive ? {
                color: s.color, bgcolor: s.bg, borderColor: s.border,
              } : {},
            }}
          >
            {isUpdating && isActive
              ? <CircularProgress size={10} sx={{ color: s.color }} />
              : step.label
            }
          </Box>
        );
      })}
    </Box>
  );
}

export default function DeliveryPage() {
  const dispatch = useDispatch();
  const { list, loading, updateLoading } = useSelector((state) => state.delivery);
  const [activeFilter, setActiveFilter] = useState("all");

  useEffect(() => { dispatch(fetchDeliveryOrders()); }, [dispatch]);

  const handleFilterChange = (key) => {
    setActiveFilter(key);
    dispatch(fetchDeliveryOrders(key === "all" ? null : key));
  };

  const handleUpdate = async (id, delivery_status) => {
    try {
      await dispatch(updateDeliveryStatus({ id, delivery_status })).unwrap();
      toast.success(`  updated to : ${STATUSES[delivery_status].label}`);
    } catch (err) {
      toast.error(err?.message ?? "fail to update status");
    }
  };

  const filtered = activeFilter === "all"
    ? list
    : list.filter((b) => b.delivery_status === activeFilter);

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
          <Typography sx={{ fontSize: 22, fontWeight: 800, color: "#fff", letterSpacing: -0.5 }}>
            Delivery Orders
          </Typography>
          <Box sx={{
            px: "10px", py: "3px", borderRadius: "20px",
            bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
            fontSize: 11, fontWeight: 600, color: "#c9a84c",
          }}>
            {filtered.length} order
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
              px: "14px", py: "6px", borderRadius: "8px",
              fontSize: 12, fontWeight: 600, cursor: "pointer",
              transition: "all .2s",
              ...(activeFilter === f.key
                ? { color: "#c9a84c", bgcolor: "rgba(201,168,76,0.07)", border: "1px solid rgba(201,168,76,0.3)" }
                : { color: "rgba(255,255,255,0.4)", bgcolor: "rgba(255,255,255,0.03)", border: "1px solid rgba(255,255,255,0.08)", "&:hover": { color: "#fff", bgcolor: "rgba(255,255,255,0.06)" } }),
            }}
          >
            {f.label}
          </Box>
        ))}
      </Box>

      <Box sx={{ bgcolor: "#0d0d14", border: "1px solid rgba(255,255,255,0.06)", borderRadius: "16px", overflow: "hidden" }}>
        <Box sx={{ display: "grid", gridTemplateColumns: COL, px: "20px", py: "10px", bgcolor: "rgba(255,255,255,0.02)", borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
          {["#", "customers", "price", " delivery status", "= update status"].map((h) => (
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
              borderBottom: i < filtered.length - 1 ? "1px solid rgba(255,255,255,0.04)" : "none",
              transition: "background .15s",
              "&:hover": { bgcolor: "rgba(255,255,255,0.02)" },
            }}
          >
            <Typography sx={{ fontSize: 12, fontWeight: 700, color: "rgba(255,255,255,0.3)" }}>
              #{bill.id}
            </Typography>

            <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
              <Avatar name={bill.customer?.name ?? "?"} index={i} />
              <Box sx={{ minWidth: 0 }}>
                <Typography sx={{ fontSize: 13, fontWeight: 600, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>
                  {bill.customer?.name}
                </Typography>
                {bill.delivery_address && (
                  <Typography sx={{ fontSize: 11, color: "rgba(255,255,255,0.3)" }}>
                    📍 {bill.delivery_address}
                  </Typography>
                )}
              </Box>
            </Box>

            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "#fff" }}>
              {fmt(bill.total_price)} ل.س
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
            <Typography sx={{ fontSize: 13, color: "rgba(255,255,255,0.2)" }}>
No Delivery orders             </Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}