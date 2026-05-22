import React from "react";
import {
  Box,
  Typography,
  Button,
  Card,
  Chip,
} from "@mui/material";
import { TrendingUp, AlertCircle, Download } from "lucide-react";

export default function FinancePage() {
  return (
    <Box
      sx={{
        p: 4,
        minHeight: "100vh",
        background: "linear-gradient(135deg,#f8f6ef,#efe9dc)",
      }}
    >
      {/* HEADER */}
      <Box
        sx={{
          mb: 4,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Box>
          <Typography sx={{ fontSize: "2rem", fontWeight: 700 }}>
            Financial Overview 💰
          </Typography>
          <Typography sx={{ opacity: 0.6 }}>
            Track revenue, fines & transactions
          </Typography>
        </Box>

        <Button
          variant="contained"
          startIcon={<Download size={16} />}
          sx={{
            borderRadius: "12px",
            px: 3,
            background:
              "linear-gradient(135deg, rgb(189,170,127), rgb(150,130,90))",
            boxShadow: "0 6px 20px rgba(0,0,0,0.15)",
          }}
        >
          Export Report
        </Button>
      </Box>

      {/* STATS */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(250px,1fr))",
          gap: 3,
          mb: 4,
        }}
      >
        {/* COLLECTED */}
        <Card
          sx={{
            p: 3,
            borderRadius: "20px",
            background: "rgba(255,255,255,0.7)",
            backdropFilter: "blur(10px)",
            boxShadow: "0 12px 30px rgba(0,0,0,0.08)",
          }}
        >
          <Box sx={{ display: "flex", justifyContent: "space-between" }}>
            <Typography sx={{ opacity: 0.6 }}>
              Collected Fines
            </Typography>
            <TrendingUp color="#4caf50" />
          </Box>

          <Typography sx={{ fontSize: "1.8rem", fontWeight: 700, mt: 1 }}>
            $1,420.50
          </Typography>

          <Typography sx={{ fontSize: "0.75rem", color: "#4caf50" }}>
            +12% this month
          </Typography>
        </Card>

        {/* PENDING */}
        <Card
          sx={{
            p: 3,
            borderRadius: "20px",
            background: "rgba(255,255,255,0.7)",
            backdropFilter: "blur(10px)",
            boxShadow: "0 12px 30px rgba(0,0,0,0.08)",
          }}
        >
          <Box sx={{ display: "flex", justifyContent: "space-between" }}>
            <Typography sx={{ opacity: 0.6 }}>
              Pending Fines
            </Typography>
            <AlertCircle color="#ff9800" />
          </Box>

          <Typography sx={{ fontSize: "1.8rem", fontWeight: 700, mt: 1 }}>
            $320.00
          </Typography>

          <Typography sx={{ fontSize: "0.75rem", color: "#ff9800" }}>
            Needs attention
          </Typography>
        </Card>
      </Box>

      {/* TABLE */}
      <Card
        sx={{
          borderRadius: "22px",
          overflow: "hidden",
          backdropFilter: "blur(12px)",
          background: "rgba(255,255,255,0.75)",
          boxShadow: "0 20px 50px rgba(0,0,0,0.1)",
        }}
      >
        {/* HEADER */}
        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: "2fr 2fr 1fr 1fr 1fr",
            p: 2,
            fontWeight: 600,
            fontSize: "0.85rem",
            color: "#777",
            background: "rgba(0,0,0,0.02)",
          }}
        >
          <span>Member</span>
          <span>Reason</span>
          <span>Amount</span>
          <span>Date</span>
          <span>Status</span>
        </Box>

        {/* ROW */}
        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: "2fr 2fr 1fr 1fr 1fr",
            alignItems: "center",
            p: 2,
            borderTop: "1px solid rgba(0,0,0,0.05)",
            transition: "0.25s",

            "&:hover": {
              background: "rgba(255,255,255,0.9)",
              transform: "scale(1.005)",
            },
          }}
        >
          <Typography>Sara Makhlouf</Typography>
          <Typography>Late Return (3 days)</Typography>

          <Typography sx={{ fontWeight: 600 }}>
            $7.50
          </Typography>

          <Typography>April 12, 2026</Typography>

          <Chip
            label="Paid"
            size="small"
            sx={{
              bgcolor: "#e8f5e9",
              color: "#2e7d32",
              fontWeight: 500,
              borderRadius: "20px",
            }}
          />
        </Box>
      </Card>
    </Box>
  );
}