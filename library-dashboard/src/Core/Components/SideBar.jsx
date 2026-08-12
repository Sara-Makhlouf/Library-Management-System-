import { NavLink, useLocation } from "react-router-dom";
import { Box, Typography,  Collapse, Menu, MenuItem } from "@mui/material";
import { useState } from "react";
import {
      NAV_ITEMS,
      USER_SUBNAV,
      } from "../../Features/Utils/sidebarData";

import {GOLD_DARK , MUTED,GOLDDIM,GOLDBORDER,SURFACE,BRIGHT,HOVER,goldA,TEXT} from "../Constants/ColorsUse";

export default function Sidebar({
  collapsed,
  setCollapsed,
}) {
  const [openUsers, setOpenUsers] = useState(false);
  const location = useLocation();
  const usersActive = location.pathname.startsWith("/users");
const [anchorEl, setAnchorEl] = useState(null);

const menuOpen = Boolean(anchorEl);
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
    color: isActive ? GOLD_DARK : MUTED,
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
      color: isActive ? GOLD_DARK : BRIGHT,
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
        bgcolor: SURFACE,
        borderRight: `1px solid ${goldA(0.15)}`,
        boxShadow: "2px 0 16px rgba(201,168,76,.06)",
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
    width: 42,
    height: 42,
    minWidth: 42,
    borderRadius: "12px",

    background: `
      linear-gradient(
        145deg,
        rgba(201,168,76,0.28),
        rgba(139,94,26,0.12)
      )
    `,

    display: "flex",
    alignItems: "center",
    justifyContent: "center",

    border: "1px solid rgba(201,168,76,0.45)",

    boxShadow: `
      0 0 0 3px rgba(201,168,76,0.06),
      0 5px 18px rgba(139,94,26,0.18),
      inset 0 1px 0 rgba(255,255,255,0.2)
    `,

    overflow: "hidden",

    transition: "all 0.25s ease",

    "&:hover": {
      transform: "translateY(-1px) scale(1.03)",
      boxShadow: `
        0 0 0 4px rgba(201,168,76,0.08),
        0 7px 22px rgba(139,94,26,0.25)
      `,
    },
  }}
>
  <img
    src="/adminlogo.png"
    alt="Admin Logo"
    style={{
      width: "32px",
      height: "32px",
      objectFit: "contain",
      display: "block",
    }}
  />
</Box>

          {!collapsed && (
            <Box sx={{ overflow: "hidden" }}>
              <Typography
                sx={{ fontWeight: 700, fontSize: "13.5px", color: TEXT, letterSpacing: -0.3, lineHeight: 1.2 }}
              >
                Scholarly Curator
              </Typography>
              <Typography
                sx={{ fontSize: "9px", fontWeight: 600, color: GOLD_DARK, letterSpacing: "1.5px", mt: "2px" }}
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
            bgcolor: goldA(0.08),
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            cursor: "pointer",
            color: MUTED,
            transition: "all 0.2s",
            ml: collapsed ? 0 : 0,
            "&:hover": { bgcolor: goldA(0.16), color: TEXT },
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
  <Box
    sx={navItem(usersActive)}
    onClick={(e) => {
      if (collapsed) {
        setAnchorEl(e.currentTarget);
      } else {
        setOpenUsers(!openUsers);
      }
    }}
  >
    <span className="material-symbols-outlined" style={iconStyle}>
      person
    </span>

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
          <span
            className="material-symbols-outlined"
            style={{ fontSize: 16 }}
          >
            expand_more
          </span>
        </Box>
      </>
    )}
  </Box>

  <Menu
    anchorEl={anchorEl}
    open={menuOpen}
    onClose={() => setAnchorEl(null)}
    anchorOrigin={{
      vertical: "center",
      horizontal: "right",
    }}
    transformOrigin={{
      vertical: "center",
      horizontal: "left",
    }}
    PaperProps={{
      sx: {
        bgcolor: SURFACE,
        border: `1px solid ${goldA(0.18)}`,
        borderRadius: "12px",
        minWidth: 160,
        ml: 1,
        boxShadow: "0 12px 30px rgba(43,36,22,0.14)",

        "& .MuiMenuItem-root": {
          color: MUTED,
          fontSize: "13px",

          "&:hover": {
            bgcolor: HOVER,
            color: GOLD_DARK,
          },
        },
      },
    }}
  >
    {USER_SUBNAV.map(({ to, label }) => (
      <MenuItem
        key={to}
        component={NavLink}
        to={to}
        onClick={() => setAnchorEl(null)}
      >
        {label}
      </MenuItem>
    ))}
  </Menu>

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
      <Box
        sx={{
          pl: "28px",
          mt: "2px",
          display: "flex",
          flexDirection: "column",
          gap: "2px",
        }}
      >
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
                  color: isActive ? GOLD_DARK : MUTED,
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

                  "&:hover": {
                    color: BRIGHT,
                    bgcolor: HOVER,
                  },
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

        <Box sx={{ height: "1px", bgcolor: goldA(0.15), my: "8px" }} />

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
          borderTop: `1px solid ${goldA(0.15)}`,
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
            "&:hover": { color: "#c8433d", bgcolor: "rgba(226,75,74,0.08)" },
          }}
        >
          <span className="material-symbols-outlined" style={{ fontSize: 18 }}>logout</span>
          {!collapsed && "Logout"}
        </Box>
      </Box>
    </Box>
  );
}