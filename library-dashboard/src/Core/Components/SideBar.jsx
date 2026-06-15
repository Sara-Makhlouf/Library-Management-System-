import { NavLink, useLocation } from "react-router-dom";
import { Box, Typography, Collapse } from "@mui/material";
import { useState } from "react";

const NAV_ITEMS = [
  { to: "/dashboard",  icon: "dashboard",      label: "Dashboard" },
  { to: "/inventory",  icon: "menu_book",       label: "Book Inventory" },
  { to: "/analytics",  icon: "analytics",       label: "Analytics" },
  { to: "/order",      icon: "shopping_cart",   label: "Orders" },
  //{ to: "/finance",    icon: "payments",        label: "Finances" },
  //{ to: "/archives",   icon: "archive",         label: "Archives" },
{to:"/bookrequest", icon:"request_page", label:"BookRequest"},
{to:"/waitinglist", icon:"hourglass_top", label:"WaitingBooks"},
{to:"/bills", icon:"receipt_long", label:"Bills"},
{to:"/transactions", icon:"sync_alt", label:"Transactions"}
];

const USER_SUBNAV = [
  { to: "/users/list",     label: "List" },
  { to: "/users/profiles", label: "Profiles" },
];

const GOLD   = "#c9a84c";
const GOLDDIM = "rgba(201,168,76,0.08)";
const GOLDBORDER = "rgba(201,168,76,0.18)";
const MUTED  = "rgba(255,255,255,0.38)";
const BRIGHT = "rgba(255,255,255,0.82)";
const HOVER  = "rgba(255,255,255,0.04)";

export default function Sidebar() {
  const [openUsers, setOpenUsers] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const location = useLocation();
  const usersActive = location.pathname.startsWith("/users");

  const navItem = (isActive) => ({
    display: "flex",
    alignItems: "center",
    justifyContent: collapsed ? "center" : "flex-start",
    gap: collapsed ? 0 : "11px",
    px: "10px",
    py: "9px",
    borderRadius: "10px",
    fontSize: "13px",
    fontWeight: isActive ? 600 : 500,
    color: isActive ? GOLD : MUTED,
    cursor: "pointer",
    transition: "all 0.2s",
    border: "1px solid transparent",
    textDecoration: "none",
    whiteSpace: "nowrap",
    overflow: "hidden",
    ...(isActive && {
      bgcolor: GOLDDIM,
      borderColor: GOLDBORDER,
    }),
    "&:hover": {
      color: isActive ? GOLD : BRIGHT,
      bgcolor: isActive ? GOLDDIM : HOVER,
    },
  });

  const iconStyle = {
    fontSize: "18px",
    minWidth: "18px",
    color: "inherit",
  };

  return (
    <Box
      sx={{
        width: collapsed ? 68 : 240,
        height: "100vh",
        position: "fixed",
        left: 0,
        top: 0,
        px: collapsed ? "10px" : "14px",
        py: "20px",
        display: "flex",
        flexDirection: "column",
        bgcolor: "#0d0d14",
        borderRight: "1px solid rgba(255,255,255,0.05)",
        transition: "width 0.3s ease, padding 0.3s ease",
        zIndex: 100,
        overflowX: "hidden",
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: collapsed ? "center" : "space-between",
          mb: "28px",
          minHeight: 40,
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", gap: "10px", overflow: "hidden" }}>
          <Box
            sx={{
              width: 34,
              height: 34,
              minWidth: 34,
              borderRadius: "10px",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 16,
            }}
          >
            📚
          </Box>

          {!collapsed && (
            <Box sx={{ overflow: "hidden" }}>
              <Typography
                sx={{ fontWeight: 700, fontSize: "13.5px", color: "#fff", letterSpacing: -0.3, lineHeight: 1.2 }}
              >
                Scholarly Curator
              </Typography>
              <Typography
                sx={{ fontSize: "9px", fontWeight: 600, color: "rgba(201,168,76,0.6)", letterSpacing: "1.5px", mt: "2px" }}
              >
                INSTITUTIONAL LMS
              </Typography>
            </Box>
          )}
        </Box>

        <Box
          onClick={() => setCollapsed(!collapsed)}
          sx={{
            width: 28,
            height: 28,
            minWidth: 28,
            borderRadius: "8px",
            bgcolor: "rgba(255,255,255,0.05)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            cursor: "pointer",
            color: MUTED,
            transition: "all 0.2s",
            ml: collapsed ? 0 : 0,
            "&:hover": { bgcolor: "rgba(255,255,255,0.1)", color: "#fff" },
          }}
        >
          <span className="material-symbols-outlined" style={{ fontSize: 17 }}>
            {collapsed ? "menu_open" : "menu"}
          </span>
        </Box>
      </Box>

      <Box sx={{ flex: 1, display: "flex", flexDirection: "column", gap: "2px", overflow: "hidden" }}>

        {NAV_ITEMS.map(({ to, icon, label }) => (
          <NavLink key={to} to={to} style={{ textDecoration: "none" }}>
            {({ isActive }) => (
              <Box sx={navItem(isActive)}>
                <span className="material-symbols-outlined" style={iconStyle}>{icon}</span>
                {!collapsed && label}
              </Box>
            )}
          </NavLink>
        ))}

        <Box sx={{ position: "relative" }}>
          <Box sx={navItem(usersActive)} onClick={() => !collapsed && setOpenUsers(!openUsers)}>
            <span className="material-symbols-outlined" style={iconStyle}>person</span>
            {!collapsed && (
              <>
                <Box sx={{ flex: 1 }}>Users</Box>
                <Box
                  sx={{
                    display: "flex",
                    alignItems: "center",
                    color: MUTED,
                    transition: "transform 0.25s",
                    transform: openUsers ? "rotate(180deg)" : "rotate(0deg)",
                  }}
                >
                  <span className="material-symbols-outlined" style={{ fontSize: 16 }}>expand_more</span>
                </Box>
              </>
            )}
          </Box>

          {/* Vertical line */}
          {!collapsed && (
            <Box
              sx={{
                position: "absolute",
                left: "19px",
                top: "38px",
                width: "1.5px",
                height: openUsers ? "90px" : "0px",
                bgcolor: GOLDBORDER,
                transition: "height 0.3s ease",
              }}
            />
          )}

          {!collapsed && (
            <Collapse in={openUsers}>
              <Box sx={{ pl: "28px", mt: "2px", display: "flex", flexDirection: "column", gap: "2px" }}>
                {USER_SUBNAV.map(({ to, label }) => (
                  <NavLink key={to} to={to} style={{ textDecoration: "none" }}>
                    {({ isActive }) => (
                      <Box
                        sx={{
                          position: "relative",
                          display: "flex",
                          alignItems: "center",
                          px: "10px",
                          py: "7px",
                          borderRadius: "8px",
                          fontSize: "12.5px",
                          fontWeight: isActive ? 600 : 400,
                          color: isActive ? GOLD : MUTED,
                          transition: "all 0.2s",
                          cursor: "pointer",
                          "&::before": {
                            content: '""',
                            position: "absolute",
                            left: "-9px",
                            top: "50%",
                            transform: "translateY(-50%)",
                            width: "7px",
                            height: "1.5px",
                            bgcolor: GOLDBORDER,
                          },
                          "&:hover": { color: BRIGHT, bgcolor: HOVER },
                        }}
                      >
                        {label}
                      </Box>
                    )}
                  </NavLink>
                ))}
              </Box>
            </Collapse>
          )}
        </Box>

        <Box sx={{ height: "1px", bgcolor: "rgba(255,255,255,0.05)", my: "8px" }} />

        <NavLink to="/settings" style={{ textDecoration: "none" }}>
          {({ isActive }) => (
            <Box sx={navItem(isActive)}>
              <span className="material-symbols-outlined" style={iconStyle}>settings</span>
              {!collapsed && "Settings"}
            </Box>
          )}
        </NavLink>
      </Box>

      <Box
        sx={{
          mt: "auto",
          pt: "14px",
          borderTop: "1px solid rgba(255,255,255,0.05)",
        }}
      >
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            gap: "10px",
            px: "10px",
            py: "8px",
            borderRadius: "10px",
            mb: "4px",
            overflow: "hidden",
            whiteSpace: "nowrap",
          }}
        >
          <Box
            sx={{
              width: 32,
              height: 32,
              minWidth: 32,
              borderRadius: "9px",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "11px",
              fontWeight: 700,
              color: "#fff",
            }}
          >
            SM
          </Box>

          {!collapsed && (
            <Box>
              <Typography sx={{ fontSize: "13px", fontWeight: 600, color: BRIGHT, lineHeight: 1.3 }}>
                Sara Makhlouf
              </Typography>
              <Typography sx={{ fontSize: "10px", color: MUTED }}>
                Administrator
              </Typography>
            </Box>
          )}
        </Box>

        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent: collapsed ? "center" : "flex-start",
            gap: "10px",
            px: "10px",
            py: "8px",
            borderRadius: "10px",
            cursor: "pointer",
            fontSize: "13px",
            color: MUTED,
            whiteSpace: "nowrap",
            overflow: "hidden",
            transition: "all 0.2s",
            "&:hover": { color: "#e24b4a", bgcolor: "rgba(226,75,74,0.06)" },
          }}
        >
          <span className="material-symbols-outlined" style={{ fontSize: 18 }}>logout</span>
          {!collapsed && "Logout"}
        </Box>
      </Box>
    </Box>
  );
}