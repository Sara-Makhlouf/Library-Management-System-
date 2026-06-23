import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress, Collapse, IconButton, Tooltip, Dialog, DialogContent, DialogActions, Button } from "@mui/material";
import { Trash2, TriangleAlert } from "lucide-react";
import { fetchUsers, deleteUser, getAllOperationForUser } from "../../Core/Redux/Thunks/UserThunk";

// ─── Constants ────────────────────────────────────────────────────────────────
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

const COL = "2fr 2fr 1fr 1fr 130px 50px";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

// ─── Sub-components ───────────────────────────────────────────────────────────
function Avatar({ name, index }) {
  return (
    <Box sx={{
      width: 32, height: 32, minWidth: 32, borderRadius: "9px",
      background: GRADIENTS[index % GRADIENTS.length],
      display: "flex", alignItems: "center", justifyContent: "center",
      fontSize: 12, fontWeight: 700, color: TEXT,
    }}>
      {initials(name)}
    </Box>
  );
}

function RoleChip({ role }) {
  const isAdmin = role?.toLowerCase() === "admin";
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center",
      px: "8px", py: "3px", borderRadius: "6px",
      fontSize: 11, fontWeight: 600,
      ...(isAdmin
        ? { bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)", color: GOLD }
        : { bgcolor: "rgba(127,119,221,0.1)", border: "1px solid rgba(127,119,221,0.2)", color: "#7f77dd" }),
    }}>
      {role}
    </Box>
  );
}

function StatusChip({ active }) {
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center", gap: "5px",
      px: "8px", py: "3px", borderRadius: "6px",
      fontSize: 11, fontWeight: 600,
      ...(active
        ? { bgcolor: "rgba(29,158,117,0.1)", border: "1px solid rgba(29,158,117,0.2)", color: "#1d9e75" }
        : { bgcolor: "rgba(255,255,255,0.05)", border: `1px solid ${BORDER}`, color: MUTED }),
    }}>
      <Box sx={{ width: 5, height: 5, borderRadius: "50%", bgcolor: "currentColor" }} />
      {active ? "Active" : "Inactive"}
    </Box>
  );
}

// ─── Financial Panel ──────────────────────────────────────────────────────────
function FinancialPanel({ data }) {
  if (!data?.profile || !data?.financial_summary) return null;
  const { profile: p, financial_summary: fs } = data;

  const stats = [
    { label: "Borrowed",      value: fs.borrowed_count                  },
    { label: "Purchased",     value: fs.purchased_count                  },
    { label: "Fines Paid",    value: `${fs.total_fines_paid} `       },
    { label: "Total Spent",   value: `${fs.total_spend} `, gold: true },
  ];

  return (
    <Box sx={{ mx: "16px", mb: "14px" }}>
      <Box sx={{
        bgcolor: "rgba(255,255,255,0.02)",
        border: `1px solid ${BORDER}`,
        borderRadius: "12px",
        overflow: "hidden",
      }}>
        {/* ── Profile header ── */}
        <Box sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          px: "16px", py: "11px",
          borderBottom: "1px solid rgba(255,255,255,0.05)",
          bgcolor: "rgba(201,168,76,0.03)",
        }}>
          <Box>
            <Typography sx={{ ...display, fontSize: 13, fontWeight: 600, color: GOLD, mb: "2px" }}>
              {p.name}
            </Typography>
            <Typography sx={{ ...mono, fontSize: 10, color: MUTED }}>
              {p.member_type} · 📞 {p.phone}
            </Typography>
          </Box>
          <Box sx={{
            ...mono,
            display: "inline-flex", alignItems: "center", gap: "3px",
            px: "8px", py: "2px", borderRadius: "5px",
            bgcolor: "rgba(201,168,76,0.08)",
            fontSize: 10, fontWeight: 600, color: "rgba(201,168,76,0.7)",
          }}>
            ⭐ {p.points} pts
          </Box>
        </Box>

        {/* ── Stats grid ── */}
        <Box sx={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)" }}>
          {stats.map(({ label, value, gold }, i) => (
            <Box key={label} sx={{
              px: "16px", py: "12px",
              borderRight: i < 3 ? "1px solid rgba(255,255,255,0.04)" : "none",
            }}>
              <Typography sx={{ ...mono, fontSize: 10, color: MUTED2, mb: "5px" }}>
                {label}
              </Typography>
              <Typography sx={{ ...display, fontSize: 15, fontWeight: 700, color: gold ? GOLD : TEXT }}>
                {value}
              </Typography>
            </Box>
          ))}
        </Box>
      </Box>
    </Box>
  );
}

// ─── Main Page ────────────────────────────────────────────────────────────────
export default function UsersCardsPage() {
  const dispatch = useDispatch();
  const { users, selectedUserOperations, loading, operationsLoading } =
    useSelector((state) => state.user);

  const [selectedUserId, setSelectedUserId] = useState(null);
  const [deleteTarget, setDeleteTarget]     = useState(null);
  const [deleting, setDeleting]             = useState(false);

  useEffect(() => { injectFonts(); }, []);
  useEffect(() => { dispatch(fetchUsers()); }, [dispatch]);

  const handleToggle = (userId) => {
    if (selectedUserId === userId) { setSelectedUserId(null); return; }
    setSelectedUserId(userId);
    dispatch(getAllOperationForUser(userId));
  };

  const handleConfirmDelete = async () => {
    if (!deleteTarget) return;
    setDeleting(true);
    try {
      await dispatch(deleteUser(deleteTarget.id)).unwrap();
      if (selectedUserId === deleteTarget.id) setSelectedUserId(null);
      setDeleteTarget(null);
    } catch (err) {
      console.error("Failed to delete user:", err);
    } finally {
      setDeleting(false);
    }
  };

  const userList = Array.isArray(users) ? users : [];

  if (loading && userList.length === 0) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: BG, display: "flex", alignItems: "center", justifyContent: "center" }}>
        <CircularProgress sx={{ color: GOLD }} />
      </Box>
    );
  }

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      {/* ── Header bar ── */}
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
            👤
          </Box>
          <Typography sx={{ ...display, fontWeight: 600, fontSize: 16, color: TEXT, letterSpacing: -0.2 }}>
            Users
          </Typography>
        </Box>

        <Box sx={{
          ...mono,
          px: "12px", py: "5px", borderRadius: "8px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11.5, fontWeight: 600, color: GOLD,
        }}>
          {userList.length} {userList.length === 1 ? "user" : "users"}
        </Box>
      </Box>

      {/* ── Stats row ── */}
      {userList.length > 0 && (
        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "repeat(3,1fr)" }, gap: 2, mb: 2.5 }}>
          {[
            { label: "Total Users",    value: userList.length                                         },
            { label: "Active",         value: userList.filter((u) => u.is_active === 1).length        },
            { label: "Admins",         value: userList.filter((u) => u.type?.toLowerCase() === "admin").length },
          ].map(({ label, value }) => (
            <Box key={label} sx={{ bgcolor: SURFACE, border: `1px solid ${BORDER}`, borderRadius: "16px", p: "18px 20px" }}>
              <Typography sx={{ ...mono, fontSize: 10, fontWeight: 600, letterSpacing: "0.7px", color: MUTED2, textTransform: "uppercase", mb: "8px" }}>
                {label}
              </Typography>
              <Typography sx={{ ...display, fontSize: 26, fontWeight: 600, color: TEXT, letterSpacing: "-0.5px" }}>
                {value}
              </Typography>
            </Box>
          ))}
        </Box>
      )}

      {/* ── Subtitle ── */}
      <Typography sx={{ fontSize: 12, color: MUTED2, mb: 1.5, pl: "2px" }}>
        Click any row to expand financial summary
      </Typography>

      {/* ── Table ── */}
      <Box sx={{ bgcolor: "#0d0d14", border: `1px solid ${BORDER}`, borderRadius: "18px", overflow: "hidden" }}>

        {/* Head */}
        <Box sx={{
          display: "grid", gridTemplateColumns: COL,
          px: "20px", py: "10px",
          bgcolor: "rgba(255,255,255,0.02)",
          borderBottom: "1px solid rgba(255,255,255,0.05)",
        }}>
          {["User", "Email", "Role", "Status", "Financials", ""].map((h) => (
            <Typography key={h || "del"} sx={{ ...mono, fontSize: 10, fontWeight: 600, color: MUTED2, letterSpacing: "0.8px", textTransform: "uppercase" }}>
              {h}
            </Typography>
          ))}
        </Box>

        {/* Rows */}
        {userList.length === 0 ? (
          <Box sx={{ py: 8, textAlign: "center" }}>
            <Typography sx={{ ...display, fontSize: 15, fontWeight: 600, color: MUTED2, mb: 0.5 }}>
              No users found
            </Typography>
            <Typography sx={{ fontSize: 12, color: MUTED2 }}>
              No users have been added yet.
            </Typography>
          </Box>
        ) : userList.map((u, i) => {
          const isOpen        = selectedUserId === u.id;
          const isThisLoading = isOpen && operationsLoading;

          return (
            <Box key={u.id} sx={{ borderBottom: i < userList.length - 1 ? "1px solid rgba(255,255,255,0.04)" : "none" }}>

              {/* Row */}
              <Box
                onClick={() => handleToggle(u.id)}
                sx={{
                  display: "grid", gridTemplateColumns: COL,
                  px: "20px", py: "13px",
                  alignItems: "center", cursor: "pointer",
                  bgcolor: isOpen ? "rgba(201,168,76,0.03)" : "transparent",
                  transition: "background .15s",
                  "&:hover": { bgcolor: isOpen ? "rgba(201,168,76,0.04)" : "rgba(255,255,255,0.02)" },
                }}
              >
                {/* User */}
                <Box sx={{ display: "flex", alignItems: "center", gap: "10px", minWidth: 0 }}>
                  <Avatar name={u.name} index={i} />
                  <Box sx={{ minWidth: 0 }}>
                    <Typography sx={{ fontSize: 13, fontWeight: 600, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160 }}>
                      {u.name}
                    </Typography>
                  </Box>
                  <Box sx={{
                    fontSize: 11, color: isOpen ? GOLD : MUTED2,
                    transition: "transform .25s",
                    transform: isOpen ? "rotate(180deg)" : "none",
                    lineHeight: 1, flexShrink: 0,
                  }}>
                    ▾
                  </Box>
                </Box>

                {/* Email */}
                <Typography sx={{ ...mono, fontSize: 11.5, color: MUTED, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", pr: 2 }}>
                  {u.email}
                </Typography>

                {/* Role */}
                <Box><RoleChip role={u.type} /></Box>

                {/* Status */}
                <Box><StatusChip active={u.is_active === 1} /></Box>

                {/* Financials button */}
                <Box sx={{ display: "flex", justifyContent: "center" }}>
                  <Box
                    component="button"
                    onClick={(e) => { e.stopPropagation(); handleToggle(u.id); }}
                    sx={{
                      display: "inline-flex", alignItems: "center", gap: "5px",
                      px: "12px", py: "6px", borderRadius: "8px",
                      fontSize: "11.5px", fontWeight: 600, cursor: "pointer",
                      border: `1px solid ${isOpen ? "rgba(201,168,76,0.4)" : "rgba(201,168,76,0.25)"}`,
                      bgcolor: isOpen ? "rgba(201,168,76,0.12)" : "rgba(201,168,76,0.06)",
                      color: GOLD, transition: "all .2s",
                      "&:hover": { bgcolor: "rgba(201,168,76,0.15)", borderColor: "rgba(201,168,76,0.5)" },
                    }}
                  >
                    {isThisLoading
                      ? <CircularProgress size={12} sx={{ color: GOLD }} />
                      : isOpen ? "▲ Hide" : "📊 View"
                    }
                  </Box>
                </Box>

                {/* Delete */}
                <Box sx={{ display: "flex", justifyContent: "center" }}>
                  <Tooltip title="Delete user" arrow>
                    <IconButton
                      size="small"
                      onClick={(e) => { e.stopPropagation(); setDeleteTarget(u); }}
                      sx={{
                        borderRadius: "8px",
                        border: `1px solid ${BORDER}`,
                        bgcolor: "rgba(255,255,255,0.03)",
                        color: "rgba(248,113,113,0.6)",
                        "&:hover": { bgcolor: "rgba(248,113,113,0.12)", borderColor: "rgba(248,113,113,0.3)", color: "#f87171" },
                        transition: "all .2s",
                      }}
                    >
                      <Trash2 size={15} />
                    </IconButton>
                  </Tooltip>
                </Box>
              </Box>

              {/* Expanded financial panel */}
              <Collapse in={isOpen && !isThisLoading} unmountOnExit>
                <FinancialPanel data={selectedUserOperations} />
              </Collapse>
            </Box>
          );
        })}
      </Box>

      {/* ── Delete confirmation dialog ── */}
      <Dialog
        open={Boolean(deleteTarget)}
        onClose={() => !deleting && setDeleteTarget(null)}
        PaperProps={{
          sx: {
            borderRadius: "20px",
            minWidth: "380px", maxWidth: "420px",
            bgcolor: "#1a1a24",
            border: "1px solid rgba(248,113,113,0.18)",
            boxShadow: "0 24px 60px rgba(0,0,0,0.5)",
          },
        }}
      >
        <DialogContent sx={{ p: "28px 26px 8px" }}>
          <Box sx={{
            width: 44, height: 44, borderRadius: "12px",
            bgcolor: "rgba(248,113,113,0.12)",
            display: "flex", alignItems: "center", justifyContent: "center",
            mb: 2,
          }}>
            <TriangleAlert size={20} color="#f87171" />
          </Box>

          <Typography sx={{ ...display, fontSize: 17, fontWeight: 600, color: TEXT, mb: 0.8 }}>
            Delete user?
          </Typography>
          <Typography sx={{ fontSize: 13, color: MUTED, lineHeight: 1.6, mb: 2.2 }}>
            This action is permanent and cannot be undone.
          </Typography>

          {deleteTarget && (
            <Box sx={{
              display: "flex", alignItems: "center", gap: 1.4,
              p: "10px 12px", borderRadius: "12px",
              bgcolor: "rgba(255,255,255,0.03)", border: `1px solid ${BORDER}`,
            }}>
              <Avatar name={deleteTarget.name} index={0} />
              <Box sx={{ minWidth: 0 }}>
                <Typography sx={{ ...display, fontWeight: 600, fontSize: 13, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                  {deleteTarget.name}
                </Typography>
                <Typography sx={{ ...mono, fontSize: 11, color: MUTED2 }}>
                  {deleteTarget.email}
                </Typography>
              </Box>
            </Box>
          )}
        </DialogContent>

        <DialogActions sx={{ px: "26px", pb: "24px", pt: 2, gap: 1 }}>
          <Button
            onClick={() => setDeleteTarget(null)}
            disabled={deleting}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 600,
              fontSize: 13.5, color: MUTED, border: `1px solid ${BORDER}`, px: 2.5,
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
              fontWeight: 700, fontSize: 13.5, px: 2.8, color: TEXT,
              background: "linear-gradient(135deg,#f87171,#c83737)",
              "&:hover": { background: "linear-gradient(135deg,#fb8585,#d94545)", boxShadow: "0 12px 28px rgba(248,113,113,0.25)" },
              "&.Mui-disabled": { color: "rgba(255,255,255,0.6)" },
            }}
          >
            {deleting ? <CircularProgress size={16} sx={{ color: TEXT }} /> : "Delete"}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}