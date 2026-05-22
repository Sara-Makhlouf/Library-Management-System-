import React, { useState } from "react";
import { motion } from "framer-motion";
import {
  User,
  Book,
  Shield,
  Save,
  Camera,
  LogOut,
  Key,
  Activity,
} from "lucide-react";

import {
  Box,
  Typography,
  Button,
  TextField,
  Switch,
} from "@mui/material";

export default function LibrarySettings() {
  const [activeTab, setActiveTab] = useState("profile");

  const [settings, setSettings] = useState({
    name: "Admin User",
    role: "Head Librarian",
    email: "admin@library.com",
    libName: "Central Library",
    loanPeriod: 14,
    finePerDay: 2.5,
    twoFactor: true,
  });

  const handleChange = (e) => {
    const { name, value, checked, type } = e.target;
    setSettings({
      ...settings,
      [name]: type === "checkbox" ? checked : value,
    });
  };

  const tabs = [
    { id: "profile", label: "Profile", icon: <User size={18} /> },
    { id: "library", label: "Library", icon: <Book size={18} /> },
    { id: "security", label: "Security", icon: <Shield size={18} /> },
    { id: "system", label: "System", icon: <Activity size={18} /> },
  ];

  return (
    <Box
      sx={{
      
        display: "flex",
        minHeight: "100vh",
        background:
          "linear-gradient(135deg, #f8f6ef, #efe9dc)",
      }}
    >
      {/*  SIDEBAR */}
      <Box
        sx={{
          width: 270,
          p: 3,
          display: "flex",
          flexDirection: "column",
          backdropFilter: "blur(12px)",
          background: "rgba(255,255,255,0.7)",
          borderRight: "1px solid rgba(0,0,0,0.05)",
        }}
      >
        {/* PROFILE */}
        <Box sx={{ textAlign: "center", mb: 4 }}>
          <Box
            sx={{
              width: 90,
              height: 90,
              borderRadius: "50%",
              mx: "auto",
              mb: 1,
              background:
                "linear-gradient(135deg, rgb(189,170,127), rgb(150,130,90))",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontWeight: 700,
              fontSize: "1.5rem",
              color: "#fff",
              position: "relative",
              boxShadow: "0 8px 20px rgba(0,0,0,0.2)",
            }}
          >
            A
            <Box
              sx={{
                position: "absolute",
                bottom: 5,
                right: 5,
                background: "#312816",
                borderRadius: "50%",
                p: 0.5,
                cursor: "pointer",
              }}
            >
              <Camera size={12} color="#fff" />
            </Box>
          </Box>

          <Typography sx={{ fontWeight: 700 }}>
            {settings.name}
          </Typography>
          <Typography sx={{ fontSize: 12, color: "#777" }}>
            {settings.role}
          </Typography>
        </Box>

        {/* TABS */}
        <Box sx={{ flex: 1 }}>
          {tabs.map((tab) => (
            <Box key={tab.id} sx={{ position: "relative" }}>
              {activeTab === tab.id && (
                <motion.div
                  layoutId="activeTab"
                  style={{
                    position: "absolute",
                    inset: 0,
                    borderRadius: "12px",
                    background:
                      "linear-gradient(135deg, #312816, #5a4a2d)",
                  }}
                />
              )}

              <Button
                onClick={() => setActiveTab(tab.id)}
                startIcon={tab.icon}
                sx={{
                  justifyContent: "flex-start",
                  mb: 1,
                  width: "100%",
                  zIndex: 1,
                  position: "relative",
                  color:
                    activeTab === tab.id ? "#fff" : "#312816",
                }}
              >
                {tab.label}
              </Button>
            </Box>
          ))}
        </Box>

        {/* LOGOUT */}
        <Button
          startIcon={<LogOut size={16} />}
          sx={{
            mt: 2,
            borderRadius: "12px",
            color: "#ff5252",
            "&:hover": {
              background: "rgba(255,82,82,0.1)",
            },
          }}
        >
          Logout
        </Button>
      </Box>

      {/* 🔥 MAIN */}
      <Box sx={{ flex: 1, p: 5 }}>
        {/* HEADER */}
        <Box
          sx={{
            display: "flex",
            justifyContent: "space-between",
            mb: 4,
          }}
        >
          <Typography sx={{ fontSize: "1.8rem", fontWeight: 800 }}>
            {tabs.find((t) => t.id === activeTab).label}
          </Typography>

          <Button
            startIcon={<Save size={16} />}
            sx={{
              borderRadius: "12px",
              px: 3,
              background:
                "linear-gradient(135deg, rgb(189,170,127), rgb(150,130,90))",
              color: "#fff",
              boxShadow: "0 6px 20px rgba(0,0,0,0.2)",
            }}
          >
            Save Changes
          </Button>
        </Box>

        {/* CONTENT */}
        <motion.div
          key={activeTab}
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <Box
            sx={{
              p: 4,
              borderRadius: "24px",
              backdropFilter: "blur(12px)",
              background: "rgba(255,255,255,0.75)",
              boxShadow: "0 20px 50px rgba(0,0,0,0.1)",
            }}
          >
            {/* PROFILE */}
            {activeTab === "profile" && (
              <Box sx={{ display: "grid", gap: 3 }}>
                <TextField label="Name" name="name" value={settings.name} onChange={handleChange}/>
                <TextField label="Role" name="role" value={settings.role} onChange={handleChange}/>
                <TextField label="Email" name="email" value={settings.email} onChange={handleChange}/>
              </Box>
            )}

            {/* LIBRARY */}
            {activeTab === "library" && (
              <Box sx={{ display: "grid", gap: 3 }}>
                <TextField label="Library Name" name="libName" value={settings.libName} onChange={handleChange}/>
                <TextField label="Loan Period" type="number" name="loanPeriod" value={settings.loanPeriod} onChange={handleChange}/>
                <TextField label="Fine per Day" type="number" name="finePerDay" value={settings.finePerDay} onChange={handleChange}/>
              </Box>
            )}

            {/* SECURITY */}
            {activeTab === "security" && (
              <Box>
                <Box sx={{ display: "flex", justifyContent: "space-between", mb: 3 }}>
                  <Box>
                    <Typography sx={{ fontWeight: 600 }}>
                      Two-Factor Authentication
                    </Typography>
                    <Typography sx={{ fontSize: 12, color: "#777" }}>
                      Extra security layer
                    </Typography>
                  </Box>

                  <Switch checked={settings.twoFactor} name="twoFactor" onChange={handleChange}/>
                </Box>

                <Button startIcon={<Key size={16} />}>
                  Change Password
                </Button>
              </Box>
            )}

            {/* SYSTEM */}
            {activeTab === "system" && (
              <Box sx={{ display: "flex", gap: 3 }}>
                <CardStat title="Storage" value="1.2GB / 5GB" />
                <CardStat title="Server" value="99.9% uptime" />
              </Box>
            )}
          </Box>
        </motion.div>
      </Box>
    </Box>
  );
}

function CardStat({ title, value }) {
  return (
    <Box
      sx={{
        flex: 1,
        p: 3,
        borderRadius: "18px",
        background: "rgba(255,255,255,0.8)",
        boxShadow: "0 10px 25px rgba(0,0,0,0.08)",
      }}
    >
      <Typography sx={{ opacity: 0.6 }}>{title}</Typography>
      <Typography sx={{ fontWeight: 700, fontSize: "1.2rem" }}>
        {value}
      </Typography>
    </Box>
  );
}