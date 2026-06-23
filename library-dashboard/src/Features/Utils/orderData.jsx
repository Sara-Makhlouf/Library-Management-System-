
import { Box, CircularProgress } from "@mui/material";

export const STATUSES = {
  pending:          { label: "Waiting",   color: "#fbbf24", bg: "rgba(251,191,36,0.1)",  border: "rgba(251,191,36,0.25)"  },
  preparing:        { label: "In progress ",   color: "#818cf8", bg: "rgba(99,102,241,0.1)",  border: "rgba(99,102,241,0.25)"  },
  out_for_delivery: { label: " Out to delivery ",    color: "#c9a84c", bg: "rgba(201,168,76,0.1)",  border: "rgba(201,168,76,0.25)"  },
  delivered:        { label: "Delivered! ",      color: "#1d9e75", bg: "rgba(29,158,117,0.1)", border: "rgba(29,158,117,0.25)" },
};

export const STEPS = [
  { key: "pending",          label: "pending" },
  { key: "preparing",        label: "preparing"  },
  { key: "out_for_delivery", label: "خرج"    },
  { key: "delivered",        label: "delivered"  },
];

export const FILTERS = [
  { key: "all",              label: "all"           },
  { key: "pending",          label: "pending ⏳  " },
  { key: "preparing",        label: "preparing 📦  " },
  { key: "out_for_delivery", label: "out_for_delivery 🚚  "  },
  { key: "delivered",        label: " delivered ✅ "   },
];

export const GRADIENTS = [
  "linear-gradient(135deg,#c9a84c,#8b5e1a)",
  "linear-gradient(135deg,#7f77dd,#4a43a0)",
  "linear-gradient(135deg,#1d9e75,#0f6b4f)",
  "linear-gradient(135deg,#97c459,#5f8e20)",
  "linear-gradient(135deg,#e06b5a,#a03322)",
];

export const COL = "70px 2fr 1.2fr 1.4fr 1fr";

export const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

export const fmt = (val) =>
  parseFloat(val || 0).toLocaleString("en-US", { minimumFractionDigits: 2 });

export function Avatar({ name, index }) {
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


export function StatusChip({ status }) {
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

export function StatusStepper({ bill, onUpdate, isUpdating }) {
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