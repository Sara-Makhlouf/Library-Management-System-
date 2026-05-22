import { NavLink } from "react-router-dom";

import { Box, Typography, Collapse } from "@mui/material";

import { useState } from "react";

import MenuIcon from "@mui/icons-material/Menu";

import ExpandMoreIcon from "@mui/icons-material/ExpandMore";

import ExpandLessIcon from "@mui/icons-material/ExpandLess";


export default function Sidebar() {
  const [openUsers, setOpenUsers] = useState(false);
  const [collapsed, setCollapsed] = useState(false);

  const navItem = (isActive) => ({
    display: "flex",
    alignItems: "center",
    justifyContent: collapsed ? "center" : "flex-start",
    gap: collapsed ? 0 : 1.5,
    px: 1.5,
    py: 1,
    borderRadius: "10px",
    fontSize: "0.9rem",
    fontWeight: isActive ? 600 : 500,
    color: "rgb(96, 82, 50)",
    position: "relative",
    cursor: "pointer",
    transition: "0.2s",

    "&:hover": {
      bgcolor: "rgba(0,0,0,0.06)",
    },

    ...(isActive && {
      bgcolor: "rgba(49,40,22,0.12)",
    }),
  });

  return (
    <Box
      sx={{
        width: collapsed ? 80 : 250,
        height: "100vh",
        position: "fixed",
        left: 0,
        top: 0,
        px: collapsed ? 1 : 2,
        py: 3,
        display: "flex",
        flexDirection: "column",
        background:
          "linear-gradient(180deg, rgb(189,170,127), rgb(175,155,110))",
        borderRight: "1px solid rgba(0,0,0,0.06)",
        transition: "0.3s ease",
      }}
    >
      {/* HEADER */}
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: collapsed ? "center" : "space-between",
        }}
      >
        {!collapsed && (
          <Box>
            <Typography sx={{ fontWeight: 700, fontSize: "1.2rem", mb: 0.5 }}>
              Scholarly Curator
            </Typography>

            <Typography sx={{ fontSize: "0.6rem", opacity: 0.8 }}>
              INSTITUTIONAL LMS
            </Typography>
          </Box>
        )}

        {/* TOGGLE BUTTON */}
        <Box
          onClick={() => setCollapsed(!collapsed)}
          sx={{
            cursor: "pointer",
            color: "rgb(96, 82, 50)",
            display: "flex",
            alignItems: "center",
          }}
        >
          <MenuIcon />
        </Box>
      </Box>

      {/* NAV */}
      <Box sx={{ mt: 3, display: "flex", flexDirection: "column", gap: 0.5 }}>

        {/* DASHBOARD */}
        <NavLink to="/dashboard" style={{ textDecoration: "none" }}>
          {({ isActive }) => (
            <Box sx={navItem(isActive)}>
              <span className="material-symbols-outlined">dashboard</span>
              {!collapsed && "Dashboard"}
            </Box>
          )}
        </NavLink>

        {/* INVENTORY */}
        <NavLink to="/inventory" style={{ textDecoration: "none" }}>
          {({ isActive }) => (
            <Box sx={navItem(isActive)}>
              <span className="material-symbols-outlined">menu_book</span>
              {!collapsed && "Book Inventory"}
            </Box>
          )}
        </NavLink>

        {/* USERS */}
        <Box sx={{ position: "relative" }}>

          {/* USERS BUTTON */}
          <Box
            sx={navItem(openUsers)}
            onClick={() => setOpenUsers(!openUsers)}
          >
            <span className="material-symbols-outlined">person</span>
            {!collapsed && "Users"}

            {!collapsed && (
              <Box sx={{ ml: "auto", display: "flex" }}>
                {openUsers ? <ExpandLessIcon /> : <ExpandMoreIcon />}
              </Box>
            )}
          </Box>

          {/* VERTICAL LINE */}
          {!collapsed && (
            <Box
              sx={{
                position: "absolute",
                left: "18px",
                top: "42px",
                width: "2px",
                height: openUsers ? "95px" : "0px",
                bgcolor: "rgba(96, 82, 50, 0.25)",
                transition: "0.3s",
              }}
            />
          )}

          {/* DROPDOWN */}
          {!collapsed && (
            <Collapse in={openUsers}>
              <Box
                sx={{
                  pl: 4,
                  mt: 0.5,
                  display: "flex",
                  flexDirection: "column",
                  gap: 0.5,
                }}
              >
                {[
                  ["/users/list", "List"],
                  ["/users/cards", "Cards"],
                  ["/users/profiles", "Profiles"],
                ].map(([path, label]) => (
                  <NavLink key={path} to={path} style={{ textDecoration: "none" }}>
                    <Box
                      sx={{
                        display: "flex",
                        alignItems: "center",
                        px: 1.5,
                        py: 0.8,
                        borderRadius: "8px",
                        fontSize: "0.85rem",
                        color: "rgb(96, 82, 50)",
                        position: "relative",
                        transition: "0.2s",

                        "&::before": {
                          content: '""',
                          position: "absolute",
                          left: "-10px",
                          width: "8px",
                          height: "2px",
                          bgcolor: "rgba(96, 82, 50, 0.25)",
                        },

                        "&:hover": {
                          bgcolor: "rgba(0,0,0,0.05)",
                        },
                      }}
                    >
                      {label}
                    </Box>
                  </NavLink>
                ))}
              </Box>
            </Collapse>
          )}
        </Box>

        {/* OTHER ITEMS */}
        <NavLink to="/analytics" style={{ textDecoration: "none" }}>
          <Box sx={navItem(false)}>
            <span className="material-symbols-outlined">analytics</span>
            {!collapsed && "Analytics"}
          </Box>
        </NavLink>

        <NavLink to="/order" style={{ textDecoration: "none" }}>
          <Box sx={navItem(false)}>
            <span className="material-symbols-outlined">shopping_cart</span>
            {!collapsed && "Orders"}
          </Box>
        </NavLink>

        <NavLink to="/finance" style={{ textDecoration: "none" }}>
          <Box sx={navItem(false)}>
            <span className="material-symbols-outlined">payments</span>
            {!collapsed && "Finances"}
          </Box>
        </NavLink>

        <NavLink to="/archives" style={{ textDecoration: "none" }}>
          <Box sx={navItem(false)}>
            <span className="material-symbols-outlined">archive</span>
            {!collapsed && "Archives"}
          </Box>
        </NavLink>

        <NavLink to="/settings" style={{ textDecoration: "none" }}>
          <Box sx={navItem(false)}>
            <span className="material-symbols-outlined">settings</span>
            {!collapsed && "Settings"}
          </Box>
        </NavLink>
      </Box>
{/* SPACER */}
<Box sx={{ height: 150 }} />
<Box
  sx={{
    display: "flex",
    flexDirection: "column",
    gap: 1,
    mt: 2,
    borderTop: "1px solid rgba(0,0,0,0.1)",
    pt: 2,
  }}
>

  {/* USER INFO */}
  <Box
    sx={{
      display: "flex",
      alignItems: "center",
      justifyContent: collapsed ? "center" : "flex-start",
      gap: 1,
      color: "rgb(96, 82, 50)",
    }}
  >
    <span className="material-symbols-outlined">
      account_circle
    </span>

    {!collapsed && (
      <Typography sx={{ fontSize: "0.85rem", fontWeight: 600 }}>
Sara Makhlouf      </Typography>
    )}
  </Box>

  {/* LOGOUT */}
  <Box
    sx={{
      display: "flex",
      alignItems: "center",
      justifyContent: collapsed ? "center" : "flex-start",
      gap: 1,
      px: 1.5,
      py: 1,
      borderRadius: "10px",
      cursor: "pointer",
      color: "rgb(96, 82, 50)",
      "&:hover": { bgcolor: "rgba(0,0,0,0.06)" },
    }}
  >
    <span className="material-symbols-outlined">logout</span>

    {!collapsed && "Logout"}
  </Box>

</Box>
 </Box>
  );
}