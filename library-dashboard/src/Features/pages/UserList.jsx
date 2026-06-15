import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, CircularProgress, Collapse, IconButton, Tooltip } from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import { fetchUsers, deleteUser, getAllOperationForUser } from "../../Core/Redux/Thunks/UserThunk";

const initials = (name = "") =>
  name.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("");

const GRADIENTS = [
  "linear-gradient(135deg,#c9a84c,#8b5e1a)",
  "linear-gradient(135deg,#7f77dd,#4a43a0)",
  "linear-gradient(135deg,#1d9e75,#0f6b4f)",
  "linear-gradient(135deg,#97c459,#5f8e20)",
  "linear-gradient(135deg,#e06b5a,#a03322)",
];

const COL = "2fr 2fr 1fr 1fr 130px 50px";

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

function RoleChip({ role }) {
  const isAdmin = role?.toLowerCase() === "admin";
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center",
      px: "8px", py: "3px", borderRadius: "6px",
      fontSize: 11, fontWeight: 600,
      ...(isAdmin
        ? { bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)", color: "#c9a84c" }
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
        : { bgcolor: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", color: "rgba(255,255,255,0.3)" }),
    }}>
      <Box sx={{ width: 5, height: 5, borderRadius: "50%", bgcolor: "currentColor" }} />
      {active ? "Active" : "Inactive"}
    </Box>
  );
}

function FinancialPanel({ data }) {
  if (!data?.profile || !data?.financial_summary) return null;
  const { profile: p, financial_summary: fs } = data;

  const stats = [
    { label: "كتب مستعارة",    value: fs.borrowed_count },
    { label: "مشتريات",        value: fs.purchased_count },
    { label: "غرامات مدفوعة", value: fs.total_fines_paid },
    { label: "إجمالي المدفوع", value: fs.total_spend, gold: true },
  ];

  return (
    <Box sx={{ mx: "16px", mb: "14px" }}>
      <Box sx={{
        bgcolor: "rgba(255,255,255,0.02)",
        border: "1px solid rgba(255,255,255,0.06)",
        borderRadius: "12px",
        overflow: "hidden",
      }}>
        <Box sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          px: "16px", py: "11px",
          borderBottom: "1px solid rgba(255,255,255,0.05)",
          bgcolor: "rgba(201,168,76,0.03)",
        }}>
          <Box>
            <Typography sx={{ fontSize: 12, fontWeight: 700, color: "#c9a84c", mb: "2px" }}>
              {p.name}
            </Typography>
            <Typography sx={{ fontSize: 10, color: "rgba(255,255,255,0.3)" }}>
              {p.member_type} · 📞 {p.phone}
            </Typography>
          </Box>
          <Box sx={{
            display: "inline-flex", alignItems: "center", gap: "3px",
            px: "8px", py: "2px", borderRadius: "5px",
            bgcolor: "rgba(201,168,76,0.08)",
            fontSize: 10, fontWeight: 600, color: "rgba(201,168,76,0.7)",
          }}>
            ⭐ {p.points} pts
          </Box>
        </Box>

        <Box sx={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)" }}>
          {stats.map(({ label, value, gold }, i) => (
            <Box
              key={label}
              sx={{
                px: "16px", py: "12px",
                borderRight: i < 3 ? "1px solid rgba(255,255,255,0.04)" : "none",
              }}
            >
              <Typography sx={{ fontSize: 10, color: "rgba(255,255,255,0.3)", mb: "5px" }}>
                {label}
              </Typography>
              <Typography sx={{
                fontSize: 15, fontWeight: 700,
                color: gold ? "#c9a84c" : "#fff",
              }}>
                {value}
              </Typography>
            </Box>
          ))}
        </Box>
      </Box>
    </Box>
  );
}

export default function UsersCardsPage() {
  const dispatch = useDispatch();
  const { users, selectedUserOperations, loading, operationsLoading } =
    useSelector((state) => state.user);

  const [selectedUserId, setSelectedUserId] = useState(null);

  useEffect(() => { dispatch(fetchUsers()); }, [dispatch]);

  const handleToggle = (userId) => {
    if (selectedUserId === userId) { setSelectedUserId(null); return; }
    setSelectedUserId(userId);
    dispatch(getAllOperationForUser(userId));
  };

  const handleDelete = async (e, userId) => {
    e.stopPropagation();
    if (!window.confirm("Are you sure you want to delete this user?")) return;
    try {
      await dispatch(deleteUser(userId)).unwrap();
      if (selectedUserId === userId) setSelectedUserId(null);
    } catch (error) {
      console.error("Failed to delete the user:", error);
    }
  };

  if (loading && users.length === 0) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: "#0a0a0f", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <CircularProgress sx={{ color: "#c9a84c" }} />
      </Box>
    );
  }

  return (
    <Box sx={{
      minHeight: "100vh",
      bgcolor: "#0a0a0f",
      p: { xs: 2, md: "24px 28px" },
      ml: { xs: 0 },
      fontFamily: "Inter, sans-serif",
    }}>
      <Box sx={{ mb: 3 }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5, mb: 0.5 }}>
          <Typography sx={{ fontSize: 22, fontWeight: 800, color: "#fff", letterSpacing: -0.5 }}>
            Users Financial Directory
          </Typography>
          {users?.length > 0 && (
            <Box sx={{
              px: "10px", py: "3px", borderRadius: "20px",
              bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
              fontSize: 11, fontWeight: 600, color: "#c9a84c",
            }}>
              {users.length} users
            </Box>
          )}
        </Box>
        <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
          Click any row to expand financial summary
        </Typography>
      </Box>

      <Box sx={{
        bgcolor: "#0d0d14",
        border: "1px solid rgba(255,255,255,0.06)",
        borderRadius: "16px",
        overflow: "hidden",
      }}>
        <Box sx={{
          display: "grid", gridTemplateColumns: COL,
          px: "20px", py: "10px",
          bgcolor: "rgba(255,255,255,0.02)",
          borderBottom: "1px solid rgba(255,255,255,0.05)",
        }}>
          {["User", "Email", "Role", "Status", "Financials", ""].map((h, i) => (
            <Box key={h || "actions"} sx={{
              fontSize: 10, fontWeight: 600,
              color: "rgba(255,255,255,0.25)",
              letterSpacing: "0.8px", textTransform: "uppercase",
              ...(i === 4 && { textAlign: "center" }),
              ...(i === 5 && { textAlign: "center" }),
            }}>
              {h}
            </Box>
          ))}
        </Box>

        {users?.length > 0 ? users.map((u, i) => {
          const isOpen = selectedUserId === u.id;
          const isThisLoading = isOpen && operationsLoading;

          return (
            <Box
              key={u.id}
              sx={{ borderBottom: i < users.length - 1 ? "1px solid rgba(255,255,255,0.04)" : "none" }}
            >
              <Box
                onClick={() => handleToggle(u.id)}
                sx={{
                  display: "grid", gridTemplateColumns: COL,
                  px: "20px", py: "13px",
                  alignItems: "center",
                  cursor: "pointer",
                  transition: "background .15s",
                  bgcolor: isOpen ? "rgba(201,168,76,0.03)" : "transparent",
                  "&:hover": { bgcolor: isOpen ? "rgba(201,168,76,0.04)" : "rgba(255,255,255,0.02)" },
                }}
              >
                <Box sx={{ display: "flex", alignItems: "center", gap: "10px" }}>
                  <Avatar name={u.name} index={i} />
                  <Typography sx={{
                    fontSize: 13, fontWeight: 600, color: "#fff",
                    whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 160,
                  }}>
                    {u.name}
                  </Typography>
                  <Box sx={{
                    fontSize: 12, color: "rgba(255,255,255,0.25)",
                    transition: "transform .25s",
                    transform: isOpen ? "rotate(180deg)" : "rotate(0deg)",
                    lineHeight: 1,
                  }}>
                    ▾
                  </Box>
                </Box>

                <Typography sx={{
                  fontSize: 12, color: "rgba(255,255,255,0.3)",
                  whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", pr: 2,
                }}>
                  {u.email}
                </Typography>

                <Box><RoleChip role={u.type} /></Box>

                <Box><StatusChip active={u.is_active === 1} /></Box>

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
                      color: "#c9a84c", transition: "all .2s",
                      "&:hover": { bgcolor: "rgba(201,168,76,0.15)", borderColor: "rgba(201,168,76,0.5)" },
                    }}
                  >
                    {isThisLoading
                      ? <CircularProgress size={12} sx={{ color: "#c9a84c" }} />
                      : isOpen ? "▲ Hide" : "📊 View"
                    }
                  </Box>
                </Box>

                <Box sx={{ display: "flex", justifyContent: "center" }}>
                  <Tooltip title="Delete user" arrow>
                    <IconButton
                      size="small"
                      onClick={(e) => handleDelete(e, u.id)}
                      sx={{
                        borderRadius: "8px",
                        border: "1px solid rgba(255,255,255,0.06)",
                        bgcolor: "rgba(255,255,255,0.03)",
                        color: "#f87171",
                        "&:hover": { bgcolor: "rgba(248,113,113,0.1)", borderColor: "rgba(248,113,113,0.3)" },
                        transition: "all .2s",
                      }}
                    >
                      <DeleteOutlineIcon sx={{ fontSize: 15 }} />
                    </IconButton>
                  </Tooltip>
                </Box>
              </Box>

              <Collapse in={isOpen && !isThisLoading} unmountOnExit>
                <FinancialPanel data={selectedUserOperations} />
              </Collapse>
            </Box>
          );
        }) : (
          <Box sx={{ py: 8, textAlign: "center" }}>
            <Typography sx={{ fontSize: 13, color: "rgba(255,255,255,0.2)" }}>No users found.</Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}