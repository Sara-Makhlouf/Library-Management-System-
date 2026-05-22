import React from "react";
import { Archive, History, Search } from "lucide-react";
import { Box, Typography, TextField, InputAdornment } from "@mui/material";

export default function ArchivesPage() {
  return (
    <Box
      sx={{
        ml: "var(--sidebar-width)",
        p: 4,
        minHeight: "100vh",
        background: "#f6f3ea",
      }}
    >
      {/* 🔥 Header */}
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
            Archives Vault
          </Typography>

          <Typography sx={{ color: "rgb(96,82,50)", mt: 1 }}>
            Secure storage of historical system data
          </Typography>
        </Box>

        {/* Illustration */}
        <Box
          component="img"
          src="https://cdn-icons-png.flaticon.com/512/3771/3771518.png"
          sx={{ width: 120, opacity: 0.9 }}
        />
      </Box>

      {/* 🔍 Search */}
      <Box
        sx={{
          mb: 4,
          display: "flex",
          justifyContent: "flex-end",
        }}
      >
        <TextField
          placeholder="Search archive..."
          size="small"
          sx={{
            width: 280,
            background: "#fff",
            borderRadius: "10px",
            boxShadow: "0 4px 12px rgba(0,0,0,0.05)",
          }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <Search size={16} />
              </InputAdornment>
            ),
          }}
        />
      </Box>

      {/* 📦 Grid */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: 4,
        }}
      >
        {/* Card 1 */}
        <Box
          sx={{
            p: 3,
            borderRadius: "18px",
            background: "#fff",
            border: "1px solid rgba(189,170,127,0.3)",
            boxShadow: "0 8px 20px rgba(0,0,0,0.05)",
            transition: "0.3s",

            "&:hover": {
              transform: "translateY(-8px)",
              boxShadow: "0 16px 40px rgba(0,0,0,0.12)",
            },
          }}
        >
          <Box
            sx={{
              width: 50,
              height: 50,
              borderRadius: "12px",
              background: "rgba(189,170,127,0.2)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              mb: 2,
              color: "#312816",
            }}
          >
            <History size={24} />
          </Box>

          <Typography
            variant="h6"
            sx={{ fontWeight: 700, color: "#312816" }}
          >
            System Logs 2025
          </Typography>

          <Typography
            sx={{ fontSize: 14, color: "rgb(96,82,50)", my: 2 }}
          >
            All checkout history for the previous academic year stored securely.
          </Typography>

          <Typography
            sx={{
              fontSize: 12,
              color: "#fff",
              background: "#312816",
              display: "inline-block",
              px: 1.5,
              py: 0.5,
              borderRadius: "6px",
              mb: 2,
            }}
          >
            Archived
          </Typography>

          <Box
            sx={{
              mt: 2,
              color: "#312816",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            View Records →
          </Box>
        </Box>

        {/* Card 2 */}
        <Box
          sx={{
            p: 3,
            borderRadius: "18px",
            background: "#fff",
            border: "1px solid rgba(189,170,127,0.3)",
            boxShadow: "0 8px 20px rgba(0,0,0,0.05)",
            transition: "0.3s",

            "&:hover": {
              transform: "translateY(-8px)",
              boxShadow: "0 16px 40px rgba(0,0,0,0.12)",
            },
          }}
        >
          <Box
            sx={{
              width: 50,
              height: 50,
              borderRadius: "12px",
              background: "rgba(189,170,127,0.2)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              mb: 2,
              color: "#312816",
            }}
          >
            <Archive size={24} />
          </Box>

          <Typography
            variant="h6"
            sx={{ fontWeight: 700, color: "#312816" }}
          >
            Decommissioned Books
          </Typography>

          <Typography
            sx={{ fontSize: 14, color: "rgb(96,82,50)", my: 2 }}
          >
            Books removed from inventory due to damage or loss.
          </Typography>

          <Typography
            sx={{
              fontSize: 12,
              color: "#312816",
              background: "rgba(189,170,127,0.3)",
              display: "inline-block",
              px: 1.5,
              py: 0.5,
              borderRadius: "6px",
              mb: 2,
            }}
          >
            Secure Vault
          </Typography>

          <Box
            sx={{
              mt: 2,
              color: "#312816",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            View List →
          </Box>
        </Box>
      </Box>
    </Box>
  );
}