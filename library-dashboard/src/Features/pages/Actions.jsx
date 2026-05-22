import React from "react";
import {
  BookPlus,
  Repeat,
  Users,
  BarChart3,
  Package,
  AlertTriangle,
} from "lucide-react";
import { Box, Typography, Button } from "@mui/material";

const actions = [
  { title: "Add New Book", icon: BookPlus },
  { title: "Borrow / Return", icon: Repeat },
  { title: "Manage Members", icon: Users },
  { title: "Reports", icon: BarChart3 },
  { title: "Inventory", icon: Package },
  { title: "Late Returns", icon: AlertTriangle },
];

export default function ActionsPage() {
  return (
    <Box
      sx={{
        ml: "var(--sidebar-width)",
        p: 4,
        minHeight: "100vh",
        background: "#f6f3ea",
      }}
    >
      {/* Header */}
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          mb: 5,
        }}
      >
        <Box>
          <Typography
            variant="h4"
            sx={{ fontWeight: 800, color: "#312816" }}
          >
            Library Dashboard
          </Typography>

          <Typography sx={{ color: "rgb(96,82,50)", mt: 1 }}>
            Manage books, members, and operations efficiently.
          </Typography>
        </Box>

        <Box
          component="img"
          src="https://cdn-icons-png.flaticon.com/512/3135/3135755.png"
          sx={{ width: 130, opacity: 0.9 }}
        />
      </Box>

      {/* Cards */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))",
          gap: 4,
        }}
      >
        {actions.map((item, i) => {
          const Icon = item.icon;

          return (
            <Box
              key={i}
              sx={{
                position: "relative",
                p: 3,
                borderRadius: "16px",
                background: "#fff",
                border: "1px solid rgba(0,0,0,0.05)",
                boxShadow: "0 6px 18px rgba(0,0,0,0.05)",
                transition: "0.3s",

                "&:hover": {
                  transform: "translateY(-8px)",
                  boxShadow: "0 16px 40px rgba(0,0,0,0.12)",
                  borderColor: "rgba(189,170,127,0.4)",
                },
              }}
            >
              {/* Accent */}
              <Box
                sx={{
                  position: "absolute",
                  top: 0,
                  left: 0,
                  height: "4px",
                  width: "100%",
                  borderTopLeftRadius: "16px",
                  borderTopRightRadius: "16px",
                  background:
                    "linear-gradient(90deg, #312816, rgb(189,170,127))",
                }}
              />

              {/* Icon */}
              <Box
                sx={{
                  width: 48,
                  height: 48,
                  borderRadius: "12px",
                  background: "rgba(189,170,127,0.15)",
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  mb: 2,
                  color: "#312816",
                }}
              >
                <Icon size={22} />
              </Box>

              {/* Title */}
              <Typography
                variant="h6"
                sx={{ fontWeight: 700, color: "#312816" }}
              >
                {item.title}
              </Typography>

              {/* Text */}
              <Typography
                sx={{
                  fontSize: 14,
                  color: "rgb(96,82,50)",
                  my: 2,
                }}
              >
                Access and manage this feature eff.
              </Typography>

              {/* Button */}
              <Button
                fullWidth
                sx={{
                  borderRadius: "10px",
                  background: "#312816",
                  color: "#fff",
                  fontWeight: 700,
                  textTransform: "none",

                  "&:hover": {
                    background: "#2a2112",
                  },
                }}
              >
                Open
              </Button>
            </Box>
          );
        })}
      </Box>
    </Box>
  );
}