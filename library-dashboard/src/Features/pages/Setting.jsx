import { useState, useEffect } from "react";
import {
  Box,
  Typography,
  TextField,
  Button,
  IconButton,
  Switch,
  Chip,
} from "@mui/material";
import { motion } from "framer-motion";

import { User, Globe, Bell, Settings, Pencil, Save } from "lucide-react";

import { useDispatch, useSelector } from "react-redux";
import { fetchSettings, updateSettingsThunk,sendNotification } from "../../Core/Redux/Thunks/SettingThunk";

const BG      = "#0a0a0f";
const SURFACE = "#111118";
const GOLD    = "#c9a84c";
const GOLD2   = "#8b5e1a";
const BORDER  = "rgba(255,255,255,0.06)";
const BORDER2 = "rgba(255,255,255,0.10)";
const TEXT    = "#fff";
const MUTED   = "rgba(255,255,255,0.35)";

const fieldSx = {
  "& .MuiOutlinedInput-root": {
    borderRadius: "10px", fontSize: 13.5, color: TEXT,
    bgcolor: "rgba(255,255,255,0.04)",
    "& fieldset":             { borderColor: BORDER },
    "&:hover fieldset":       { borderColor: BORDER2 },
    "&.Mui-focused fieldset": { borderColor: `${GOLD}60` },
  },
  "& .MuiInputLabel-root":             { fontSize: 13.5, color: MUTED },
  "& .MuiInputLabel-root.Mui-focused": { color: GOLD },
  "& input": { color: TEXT },
};

function SectionCard({ children, sx = {} }) {
  return (
    <Box
      component={motion.div}
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      sx={{
        p: "20px", borderRadius: "18px",
        bgcolor: SURFACE, border: `1px solid ${BORDER}`,
        transition: "all 0.25s",
        ...sx,
      }}
    >
      {children}
    </Box>
  );
}

export default function LibrarySettings() {
  const dispatch = useDispatch();
  const { settings } = useSelector((state) => state.library);

  const [formState, setFormState] = useState({});
  const [editing, setEditing] = useState(null);

  useEffect(() => { dispatch(fetchSettings()); }, [dispatch]);
  useEffect(() => { if (settings) setFormState(settings); }, [settings]);

  const handleChange = (e) => {
    setFormState({ ...formState, [e.target.name]: e.target.value });
  };

  const handleToggle = (name) => {
    setFormState({ ...formState, [name]: !formState[name] });
  };

  const saveAll = () => {
    const formattedData = Object.keys(formState).map(key => ({
    name: key,
    value: formState[key]
  }));

  dispatch(updateSettingsThunk(formattedData));
  setEditing(null);
   
  };

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      <Box
        sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          mb: 3, px: "20px", height: 60,
          bgcolor: "rgba(255,255,255,0.04)",
          border: `1px solid ${BORDER}`,
          borderRadius: "16px",
          position: "sticky", top: 0, zIndex: 10,
          backdropFilter: "blur(16px)",
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box
            sx={{
              width: 32, height: 32, borderRadius: "10px",
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              display: "flex", alignItems: "center", justifyContent: "center",
            }}
          >
            <Settings size={17} color="#fff" />
          </Box>
          <Typography sx={{ fontWeight: 700, fontSize: 15, color: TEXT, letterSpacing: -0.3 }}>
            System Settings
          </Typography>
        </Box>

        <Chip
          icon={<Settings size={14} color={GOLD} />}
          label="Admin Panel"
          sx={{
            bgcolor: "rgba(201,168,76,0.1)",
            border: "1px solid rgba(201,168,76,0.2)",
            color: GOLD, fontWeight: 700, fontSize: 11.5,
            letterSpacing: 0.3, height: 28, borderRadius: "8px",
            "& .MuiChip-icon": { ml: 1 },
          }}
        />
      </Box>

      <Box
        sx={{
          p: { xs: 3, md: "36px 40px" },
          borderRadius: "20px",
          background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
          border: "1px solid rgba(201,168,76,0.2)",
          position: "relative", overflow: "hidden",
          mb: 2.5,
        }}
      >
        <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: -60, left: -40, width: 200, height: 200, background: "radial-gradient(circle,rgba(139,94,26,0.06) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

        <Chip
          label="● Configuration"
          size="small"
          sx={{
            mb: 2.5,
            bgcolor: "rgba(201,168,76,0.1)",
            border: "1px solid rgba(201,168,76,0.2)",
            color: GOLD, fontWeight: 600, fontSize: 11,
            letterSpacing: 0.5, height: 24, borderRadius: "20px",
            "& .MuiChip-label": { px: 1.5 },
          }}
        />

        <Typography
          sx={{
            fontSize: { xs: 24, md: 32 }, fontWeight: 800,
            letterSpacing: -1, lineHeight: 1.1, mb: 1.5,
            background: `linear-gradient(135deg,${TEXT} 0%,${GOLD} 100%)`,
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text",
          }}
        >
          Platform configuration
        </Typography>

<Button
  variant="outlined"
  size="small"
  onClick={() => dispatch(sendNotification({ title: "System Notification", message: "Our library closed in freiday" }))}
  sx={{
    mt: 2, borderColor: "#97c459", color: "#97c459",
    "&:hover": { borderColor: "#97c459", bgcolor: "rgba(151,196,89,0.1)" }
  }}
>
  Send Global Notification
</Button>
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", md: "1fr 1fr" }, gap: 2, mb: 2 }}>

        <SectionCard
          sx={{
            cursor: "default",
            "&:hover": { borderColor: `${GOLD}40`, transform: "translateY(-2px)", bgcolor: "#151520" },
          }}
        >
          <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2 }}>
            <Box sx={{ display: "flex", alignItems: "center", gap: 1.2 }}>
              <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: `${GOLD}18`, color: GOLD, display: "flex", alignItems: "center", justifyContent: "center" }}>
                <User size={15} />
              </Box>
              <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
                General Information
              </Typography>
            </Box>
            <IconButton
              onClick={() => setEditing(editing === "general" ? null : "general")}
              sx={{
                width: 30, height: 30, borderRadius: "8px",
                bgcolor: "rgba(255,255,255,0.03)", border: `1px solid ${BORDER}`,
                color: MUTED,
                "&:hover": { bgcolor: "rgba(201,168,76,0.1)", borderColor: "rgba(201,168,76,0.3)", color: GOLD },
                transition: "all 0.2s",
              }}
            >
              <Pencil size={14} />
            </IconButton>
          </Box>

          {editing === "general" ? (
            <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <TextField name="site_name" label="Library Name" size="small" fullWidth
                value={formState.site_name || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="contact_email" label="Contact Email" size="small" fullWidth
                value={formState.contact_email || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="footer_copyright" label="Copyright" size="small" fullWidth
                value={formState.footer_copyright || ""} onChange={handleChange} sx={fieldSx} />
                <TextField 
      name="contact_phone" 
      label="Phone Number" 
      size="small" 
      fullWidth
      value={formState.contact_phone || ""} 
      onChange={handleChange} 
      sx={fieldSx} 
    />
              <Button
                startIcon={<Save size={15} />}
                onClick={saveAll}
                sx={{
                  borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13,
                  color: "#fff", py: 1,
                  background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
                  "&:hover": { background: "linear-gradient(135deg,#d4b562,#9e6c20)", boxShadow: "0 12px 28px rgba(201,168,76,0.25)" },
                  transition: "all 0.25s",
                }}
              >
                Save
              </Button>
            </Box>
          ) : (
            <Box sx={{ display: "flex", flexDirection: "column", gap: 1 }}>
              {[
                { label: "Library", value: formState.site_name },
                { label: "Email", value: formState.contact_email },
                { label: "Copyright", value: formState.footer_copyright },
                { label: "Phone", value: formState.contact_phone }, 
              ].map((row) => (
                <Box key={row.label} sx={{ display: "flex", justifyContent: "space-between", py: 0.8, borderBottom: `1px solid ${BORDER}` }}>
                  <Typography sx={{ fontSize: 12, color: MUTED, fontWeight: 600 }}>{row.label}</Typography>
                  <Typography sx={{ fontSize: 12.5, color: TEXT, fontWeight: 600, textAlign: "right", maxWidth: "60%", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                    {row.value || "—"}
                  </Typography>
                </Box>
              ))}
            </Box>
          )}
        </SectionCard>

        <SectionCard
          sx={{
            cursor: "default",
            "&:hover": { borderColor: `${GOLD}40`, transform: "translateY(-2px)", bgcolor: "#151520" },
          }}
        >
          <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2 }}>
            <Box sx={{ display: "flex", alignItems: "center", gap: 1.2 }}>
              <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: "rgba(127,119,221,0.18)", color: "#7f77dd", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <Globe size={15} />
              </Box>
              <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
                Social Media
              </Typography>
            </Box>
            <IconButton
              onClick={() => setEditing(editing === "social" ? null : "social")}
              sx={{
                width: 30, height: 30, borderRadius: "8px",
                bgcolor: "rgba(255,255,255,0.03)", border: `1px solid ${BORDER}`,
                color: MUTED,
                "&:hover": { bgcolor: "rgba(127,119,221,0.1)", borderColor: "rgba(127,119,221,0.3)", color: "#7f77dd" },
                transition: "all 0.2s",
              }}
            >
              <Pencil size={14} />
            </IconButton>
          </Box>

          {editing === "social" ? (
            <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <TextField name="facebook_url" label="Facebook" size="small" fullWidth
                value={formState.facebook_url || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="instagram_url" label="Instagram" size="small" fullWidth
                value={formState.instagram_url || ""} onChange={handleChange} sx={fieldSx} />
              <Button
                startIcon={<Save size={15} />}
                onClick={saveAll}
                sx={{
                  borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13,
                  color: "#fff", py: 1,
                  background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
                  "&:hover": { background: "linear-gradient(135deg,#d4b562,#9e6c20)", boxShadow: "0 12px 28px rgba(201,168,76,0.25)" },
                  transition: "all 0.25s",
                }}
              >
                Save
              </Button>
            </Box>
          ) : (
            <Box sx={{ display: "flex", flexDirection: "column", gap: 1 }}>
              {[
                { label: "Facebook", value: formState.facebook_url },
                { label: "Instagram", value: formState.instagram_url },
              ].map((row) => (
                <Box key={row.label} sx={{ display: "flex", justifyContent: "space-between", py: 0.8, borderBottom: `1px solid ${BORDER}` }}>
                  <Typography sx={{ fontSize: 12, color: MUTED, fontWeight: 600 }}>{row.label}</Typography>
                  <Typography sx={{ fontSize: 12.5, color: TEXT, fontWeight: 600, textAlign: "right", maxWidth: "60%", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                    {row.value || "—"}
                  </Typography>
                </Box>
              ))}
            </Box>
          )}
        </SectionCard>

        <SectionCard
          sx={{
            cursor: "default",
            "&:hover": { borderColor: "#97c45940", transform: "translateY(-2px)", bgcolor: "#151520" },
          }}
        >
          <Box sx={{ display: "flex", alignItems: "center", gap: 1.2, mb: 2 }}>
            <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: "rgba(151,196,89,0.18)", color: "#97c459", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Bell size={15} />
            </Box>
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
              Notifications
            </Typography>
          </Box>

          <Box sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}>
            {[
              { key: "email_notifications", label: "Email Notifications" },
              { key: "system_notifications", label: "System Alerts" },
            ].map((item) => (
              <Box
                key={item.key}
                sx={{
                  display: "flex", alignItems: "center", justifyContent: "space-between",
                  py: 1.2, px: 1, borderRadius: "10px",
                  transition: "all 0.2s",
                  "&:hover": { bgcolor: "rgba(255,255,255,0.04)" },
                }}
              >
                <Typography sx={{ fontSize: 13, color: TEXT, fontWeight: 500 }}>{item.label}</Typography>
                <Switch
                  checked={formState[item.key] || false}
                  onChange={() => handleToggle(item.key)}
                  sx={{
                    "& .MuiSwitch-switchBase.Mui-checked": { color: GOLD },
                    "& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track": { backgroundColor: GOLD, opacity: 0.4 },
                    "& .MuiSwitch-track": { backgroundColor: "rgba(255,255,255,0.15)" },
                  }}
                />
              </Box>
            ))}
          </Box>
        </SectionCard>

        <Box
          component={motion.div}
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          sx={{
            p: "20px", borderRadius: "18px",
            background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
            border: "1px solid rgba(201,168,76,0.2)",
            position: "relative", overflow: "hidden",
            display: "flex", flexDirection: "column", justifyContent: "center",
          }}
        >
          <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

          <Typography sx={{ fontSize: 15, fontWeight: 800, color: TEXT, mb: 0.8 }}>
            Global Save
          </Typography>
          <Typography sx={{ fontSize: 12.5, color: MUTED, lineHeight: 1.6, mb: 2.5 }}>
            Save all changes across system settings at once.
          </Typography>

          <Button
            fullWidth
            startIcon={<Save size={16} />}
            onClick={saveAll}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13.5,
              color: "#fff", py: 1.2,
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              "&:hover": {
                background: "linear-gradient(135deg,#d4b562,#9e6c20)",
                transform: "translateY(-1px)",
                boxShadow: "0 12px 28px rgba(201,168,76,0.25)",
              },
              transition: "all 0.25s",
            }}
          >
            Save All Changes
          </Button>
        </Box>

      </Box>
    </Box>
  );
}