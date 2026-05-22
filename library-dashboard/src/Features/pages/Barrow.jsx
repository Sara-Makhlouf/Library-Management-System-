import React from "react";
import {
  BookOpen,
  UserCheck,
 
  ArrowRightLeft,
} from "lucide-react";
import { Box, Typography, TextField, Button } from "@mui/material";

export default function CirculationPage() {
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
            Book Circulation
          </Typography>

          <Typography sx={{ color: "rgb(96,82,50)", mt: 1 }}>
            Issue or return books quickly and efficiently
          </Typography>
        </Box>

        {/* Illustration */}
        <Box
          component="img"
          src="https://cdn-icons-png.flaticon.com/512/2232/2232688.png"
          sx={{ width: 120, opacity: 0.9 }}
        />
      </Box>

      {/* 🔥 Layout */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "1.2fr 1fr",
          gap: 4,
        }}
      >
        {/* 📦 Loan Card */}
        <Box
          sx={{
            p: 3,
            borderRadius: "18px",
            background: "#fff",
            boxShadow: "0 8px 25px rgba(0,0,0,0.05)",
            border: "1px solid rgba(189,170,127,0.3)",
          }}
        >
          {/* Header */}
          <Box sx={{ display: "flex", alignItems: "center", mb: 3 }}>
            <ArrowRightLeft color="#312816" />
            <Typography
              variant="h6"
              sx={{ ml: 1, fontWeight: 700, color: "#312816" }}
            >
              New Loan
            </Typography>
          </Box>

          {/* Inputs */}
          <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
            <TextField
              label="Member ID"
              placeholder="Enter member ID or scan badge"
              InputProps={{
                startAdornment: <UserCheck size={18} />,
              }}
              sx={{ background: "#fafafa", borderRadius: "8px" }}
            />

            <TextField
              label="Book ISBN / ID"
              placeholder="Scan book barcode"
              InputProps={{
                startAdornment: <BookOpen size={18} />,
              }}
              sx={{ background: "#fafafa", borderRadius: "8px" }}
            />

            <TextField
              type="date"
              label="Return Date"
              InputLabelProps={{ shrink: true }}
              sx={{ background: "#fafafa", borderRadius: "8px" }}
            />

            <Button
              fullWidth
              sx={{
                mt: 2,
                borderRadius: "10px",
                background: "#312816",
                color: "#fff",
                fontWeight: 700,
                py: 1.2,

                "&:hover": {
                  background: "#2a2112",
                },
              }}
            >
              Complete Loan Transaction
            </Button>
          </Box>
        </Box>

        {/* 📋 Activity */}
        <Box
          sx={{
            p: 3,
            borderRadius: "18px",
            background: "#fff",
            boxShadow: "0 8px 25px rgba(0,0,0,0.05)",
            border: "1px solid rgba(189,170,127,0.3)",
          }}
        >
          <Typography
            variant="h6"
            sx={{ fontWeight: 700, color: "#312816", mb: 3 }}
          >
            Recent Transactions
          </Typography>

          <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
            {[1, 2, 3].map((i) => (
              <Box
                key={i}
                sx={{
                  display: "flex",
                  alignItems: "center",
                  gap: 2,
                  p: 2,
                  borderRadius: "12px",
                  background: "#fafafa",
                  transition: "0.3s",

                  "&:hover": {
                    background: "rgba(189,170,127,0.15)",
                  },
                }}
              >
                {/* Icon */}
                <Box
                  sx={{
                    width: 40,
                    height: 40,
                    borderRadius: "10px",
                    background: "rgba(189,170,127,0.2)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontWeight: "bold",
                    color: "#312816",
                  }}
                >
                  ↺
                </Box>

                {/* Text */}
                <Box>
                  <Typography sx={{ fontWeight: 600 }}>
                    "Atomic Habits" returned by Ahmad
                  </Typography>
                  <Typography sx={{ fontSize: 12, color: "#777" }}>
                    2 mins ago
                  </Typography>
                </Box>
              </Box>
            ))}
          </Box>
        </Box>
      </Box>
    </Box>
  );
}