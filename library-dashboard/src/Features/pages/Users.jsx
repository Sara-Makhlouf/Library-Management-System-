import React, { useState } from "react";
import { motion } from "framer-motion";
import {
  Search,
  UserPlus,
  MoreVertical,
} from "lucide-react";
import {
  Box,
  Typography,
  Button,
  TextField,
  InputAdornment,
} from "@mui/material";

export default function UsersPage() {
  const [users] = useState([
    {
      id: 1,
      name: "Ahmad Al-Saeed",
      email: "ahmad@example.com",
      role: "Student",
      joined: "2024-01-12",
      status: "Active",
    },
    {
      id: 2,
      name: "Laila Mahmoud",
      email: "laila@example.com",
      role: "Faculty",
      joined: "2023-11-05",
      status: "Inactive",
    },
  ]);

  return (
    <Box
      sx={{
        ml: "var(--sidebar-width)",
        p: 4,
        minHeight: "100vh",
        background: "#f6f3ea",
      }}
    >
      {/*  Header */}
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          mb: 4,
        }}
      >
        <Box>
          <Typography variant="h4" sx={{ fontWeight: 800, color: "#312816" }}>
            User Directory
          </Typography>
          <Typography sx={{ color: "rgb(96,82,50)" }}>
            Manage your library members
          </Typography>
        </Box>

        <Button
          startIcon={<UserPlus size={18} />}
          sx={{
            background: "#312816",
            color: "#fff",
            fontWeight: 700,
            borderRadius: "10px",
            px: 2,
            "&:hover": { background: "#2a2112" },
          }}
        >
          Add User
        </Button>
      </Box>

      {/* 📊 Stats */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit,minmax(200px,1fr))",
          gap: 3,
          mb: 4,
        }}
      >
        {[
          { label: "Total Users", value: "1,240" },
          { label: "Active Now", value: "85" },
          { label: "New This Month", value: "12" },
        ].map((stat, i) => (
          <Box
            key={i}
            sx={{
              p: 2,
              borderRadius: "14px",
              background: "#fff",
              border: "1px solid rgba(189,170,127,0.3)",
              boxShadow: "0 6px 15px rgba(0,0,0,0.05)",
            }}
          >
            <Typography sx={{ fontSize: 13, color: "#777" }}>
              {stat.label}
            </Typography>
            <Typography
              sx={{ fontSize: 22, fontWeight: 800, color: "#312816" }}
            >
              {stat.value}
            </Typography>
          </Box>
        ))}
      </Box>

      {/* 📋 Table Card */}
      <Box
        sx={{
          background: "#fff",
          borderRadius: "18px",
          p: 3,
          border: "1px solid rgba(189,170,127,0.3)",
          boxShadow: "0 8px 25px rgba(0,0,0,0.05)",
        }}
      >
        {/* 🔍 Search */}
        <Box sx={{ mb: 3, display: "flex", justifyContent: "flex-end" }}>
          <TextField
            size="small"
            placeholder="Search users..."
            sx={{ width: 260 }}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search size={16} />
                </InputAdornment>
              ),
            }}
          />
        </Box>

        {/* 🧾 Table */}
        <Box>
          {/* Header */}
          <Box
            sx={{
              display: "grid",
              gridTemplateColumns: "2fr 1fr 1fr 1fr 0.5fr",
              pb: 2,
              borderBottom: "1px solid #eee",
              fontWeight: 700,
              color: "#312816",
            }}
          >
            <span>Member</span>
            <span>Role</span>
            <span>Joined</span>
            <span>Status</span>
            <span></span>
          </Box>

          {/* Rows */}
          {users.map((user) => (
            <motion.div
              key={user.id}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
            >
              <Box
                sx={{
                  display: "grid",
                  gridTemplateColumns: "2fr 1fr 1fr 1fr 0.5fr",
                  alignItems: "center",
                  py: 2,
                  borderBottom: "1px solid #f1f1f1",
                  "&:hover": {
                    background: "rgba(189,170,127,0.1)",
                  },
                }}
              >
                {/* User */}
                <Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
                  <Box
                    sx={{
                      width: 40,
                      height: 40,
                      borderRadius: "50%",
                      background: "rgba(189,170,127,0.3)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontWeight: 700,
                      color: "#312816",
                    }}
                  >
                    {user.name.charAt(0)}
                  </Box>

                  <Box>
                    <Typography sx={{ fontWeight: 600 }}>
                      {user.name}
                    </Typography>
                    <Typography sx={{ fontSize: 12, color: "#777" }}>
                      {user.email}
                    </Typography>
                  </Box>
                </Box>

                {/* Role */}
                <Box>
                  <Box
                    sx={{
                      display: "inline-block",
                      px: 1.5,
                      py: 0.5,
                      borderRadius: "6px",
                      background: "rgba(189,170,127,0.3)",
                      fontSize: 12,
                      fontWeight: 600,
                    }}
                  >
                    {user.role}
                  </Box>
                </Box>

                {/* Date */}
                <Typography>{user.joined}</Typography>

                {/* Status */}
                <Box>
                  <Box
                    sx={{
                      display: "inline-block",
                      px: 1.5,
                      py: 0.5,
                      borderRadius: "6px",
                      fontSize: 12,
                      fontWeight: 600,
                      background:
                        user.status === "Active"
                          ? "rgba(0,200,0,0.1)"
                          : "rgba(200,0,0,0.1)",
                      color:
                        user.status === "Active"
                          ? "green"
                          : "red",
                    }}
                  >
                    {user.status}
                  </Box>
                </Box>

                {/* Action */}
                <Button sx={{ minWidth: 0 }}>
                  <MoreVertical size={16} />
                </Button>
              </Box>
            </motion.div>
          ))}
        </Box>
      </Box>
    </Box>
  );
}