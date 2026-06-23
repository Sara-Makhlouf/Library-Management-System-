import { useState, useEffect } from "react";
import {
  Box, Typography, TextField, Button, IconButton, Switch,
} from "@mui/material";
import { motion } from "framer-motion";
import { User, Globe, Bell, Settings, Pencil, Save } from "lucide-react";
import { useDispatch, useSelector } from "react-redux";
import { fetchSettings, updateSettingsThunk, sendNotification } from "../../Core/Redux/Thunks/SettingThunk";
import { GOLD, MUTED, TEXT, BORDER, BG, GOLD2, fieldSx, SectionCard } from "../Utils/settingData";

const display = { fontFamily: "'Fraunces', serif" };
const mono    = { fontFamily: "'IBM Plex Mono', monospace" };

const FONT_IMPORT_ID = "lib-fonts";
const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (document.getElementById(FONT_IMPORT_ID)) return;
  const link = document.createElement("link");
  link.id   = FONT_IMPORT_ID;
  link.rel  = "stylesheet";
  link.href = FONT_HREF;
  document.head.appendChild(link);
}

function InfoRow({ label, value }) {
  return (
    <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", py: "9px", borderBottom: `1px solid ${BORDER}` }}>
      <Typography sx={{ ...mono, fontSize: 10, fontWeight: 600, color: MUTED, letterSpacing: "0.6px", textTransform: "uppercase" }}>
        {label}
      </Typography>
      <Typography sx={{ fontSize: 12.5, color: TEXT, fontWeight: 600, textAlign: "right", maxWidth: "60%", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
        {value || "—"}
      </Typography>
    </Box>
  );
}

function SaveBtn({ onClick }) {
  return (
    <Button
      startIcon={<Save size={15} />}
      onClick={onClick}
      sx={{
        borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13,
        color: "#000", py: 1,
        background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
        "&:hover": { background: "linear-gradient(135deg,#d4b562,#9e6c20)", boxShadow: "0 12px 28px rgba(201,168,76,0.25)" },
        transition: "all 0.25s",
      }}
    >
      Save
    </Button>
  );
}

function SectionHeader({ icon, label, iconBg, iconColor, onEdit }) {
  return (
    <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2 }}>
      <Box sx={{ display: "flex", alignItems: "center", gap: 1.2 }}>
        <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: iconBg, color: iconColor, display: "flex", alignItems: "center", justifyContent: "center" }}>
          {icon}
        </Box>
        <Typography sx={{ ...mono, fontSize: 10, fontWeight: 700, color: "rgba(255,255,255,0.5)", letterSpacing: "0.8px", textTransform: "uppercase" }}>
          {label}
        </Typography>
      </Box>
      {onEdit && (
        <IconButton
          onClick={onEdit}
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
      )}
    </Box>
  );
}

export default function LibrarySettings() {
  const dispatch = useDispatch();
  const { settings } = useSelector((state) => state.library);

  const [formState, setFormState] = useState({});
  const [editing, setEditing]     = useState(null);

  useEffect(() => { injectFonts(); }, []);
  useEffect(() => { dispatch(fetchSettings()); }, [dispatch]);
  useEffect(() => { if (settings) setFormState(settings); }, [settings]);

  const handleChange = (e) =>
    setFormState({ ...formState, [e.target.name]: e.target.value });

  const handleToggle = (name) =>
    setFormState({ ...formState, [name]: !formState[name] });

  const saveAll = () => {
    const formattedData = Object.keys(formState).map((key) => ({ name: key, value: formState[key] }));
    dispatch(updateSettingsThunk(formattedData));
    setEditing(null);
  };

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      <Box sx={{
        display: "flex", alignItems: "center", justifyContent: "space-between",
        mb: 3, px: "20px", height: 60,
        bgcolor: "rgba(255,255,255,0.04)",
        border: `1px solid ${BORDER}`,
        borderRadius: "16px",
        position: "sticky", top: 0, zIndex: 10,
        backdropFilter: "blur(16px)",
      }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box sx={{
            width: 32, height: 32, borderRadius: "10px",
            background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
            display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Settings size={17} color="#fff" />
          </Box>
          <Typography sx={{ ...display, fontWeight: 600, fontSize: 16, color: TEXT, letterSpacing: -0.2 }}>
            System Settings
          </Typography>
        </Box>

        <Box sx={{
          ...mono,
          display: "inline-flex", alignItems: "center", gap: "6px",
          px: "12px", py: "5px", borderRadius: "8px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11.5, fontWeight: 600, color: GOLD,
        }}>
          <Settings size={13} color={GOLD} /> Admin Panel
        </Box>
      </Box>

      <Box sx={{
        p: { xs: 3, md: "32px 36px" },
        borderRadius: "20px",
        background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
        border: "1px solid rgba(201,168,76,0.2)",
        position: "relative", overflow: "hidden",
        mb: 2.5,
      }}>
        <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: -60, left: -40, width: 200, height: 200, background: "radial-gradient(circle,rgba(139,94,26,0.06) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

        <Box sx={{
          display: "inline-flex", alignItems: "center", gap: "6px",
          mb: 2.2, px: "12px", py: "4px", borderRadius: "20px",
          bgcolor: "rgba(201,168,76,0.1)", border: "1px solid rgba(201,168,76,0.2)",
          fontSize: 11, fontWeight: 600, letterSpacing: 0.5, color: GOLD,
        }}>
          ● Configuration
        </Box>

        <Typography sx={{
          ...display,
          fontSize: { xs: 24, md: 30 }, fontWeight: 600,
          letterSpacing: -0.5, lineHeight: 1.15, mb: 1.3, color: TEXT,
        }}>
          Platform <Box component="span" sx={{ color: GOLD, fontStyle: "italic" }}>configuration</Box>
        </Typography>

        <Typography sx={{ fontSize: 13.5, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 420, mb: 2.5 }}>
          Manage your library's global settings, social links, and notification preferences.
        </Typography>

        <Button
          variant="outlined"
          size="small"
          onClick={() => dispatch(sendNotification({ title: "System Notification", message: "Our library closed on Friday" }))}
          sx={{
            borderRadius: "10px", textTransform: "none", fontWeight: 600, fontSize: 12.5,
            borderColor: "#97c459", color: "#97c459",
            "&:hover": { borderColor: "#97c459", bgcolor: "rgba(151,196,89,0.08)" },
          }}
        >
          🔔 Send Global Notification
        </Button>
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", md: "1fr 1fr" }, gap: 2, mb: 2 }}>

        <SectionCard sx={{ cursor: "default", "&:hover": { borderColor: `${GOLD}40`, transform: "translateY(-2px)", bgcolor: "#151520" } }}>
          <SectionHeader
            icon={<User size={15} />}
            label="General Information"
            iconBg={`${GOLD}18`}
            iconColor={GOLD}
            onEdit={() => setEditing(editing === "general" ? null : "general")}
          />

          {editing === "general" ? (
            <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <TextField name="site_name"         label="Library Name"    size="small" fullWidth value={formState.site_name         || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="contact_email"     label="Contact Email"   size="small" fullWidth value={formState.contact_email     || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="footer_copyright"  label="Copyright"       size="small" fullWidth value={formState.footer_copyright  || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="contact_phone"     label="Phone Number"    size="small" fullWidth value={formState.contact_phone     || ""} onChange={handleChange} sx={fieldSx} />
              <SaveBtn onClick={saveAll} />
            </Box>
          ) : (
            <Box sx={{ display: "flex", flexDirection: "column" }}>
              <InfoRow label="Library"   value={formState.site_name} />
              <InfoRow label="Email"     value={formState.contact_email} />
              <InfoRow label="Copyright" value={formState.footer_copyright} />
              <InfoRow label="Phone"     value={formState.contact_phone} />
            </Box>
          )}
        </SectionCard>

        <SectionCard sx={{ cursor: "default", "&:hover": { borderColor: `${GOLD}40`, transform: "translateY(-2px)", bgcolor: "#151520" } }}>
          <SectionHeader
            icon={<Globe size={15} />}
            label="Social Media"
            iconBg="rgba(127,119,221,0.18)"
            iconColor="#7f77dd"
            onEdit={() => setEditing(editing === "social" ? null : "social")}
          />

          {editing === "social" ? (
            <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <TextField name="facebook_url"  label="Facebook"  size="small" fullWidth value={formState.facebook_url  || ""} onChange={handleChange} sx={fieldSx} />
              <TextField name="instagram_url" label="Instagram" size="small" fullWidth value={formState.instagram_url || ""} onChange={handleChange} sx={fieldSx} />
              <SaveBtn onClick={saveAll} />
            </Box>
          ) : (
            <Box sx={{ display: "flex", flexDirection: "column" }}>
              <InfoRow label="Facebook"  value={formState.facebook_url} />
              <InfoRow label="Instagram" value={formState.instagram_url} />
            </Box>
          )}
        </SectionCard>

        <SectionCard sx={{ cursor: "default", "&:hover": { borderColor: "#97c45940", transform: "translateY(-2px)", bgcolor: "#151520" } }}>
          <SectionHeader
            icon={<Bell size={15} />}
            label="Notifications"
            iconBg="rgba(151,196,89,0.18)"
            iconColor="#97c459"
          />

          <Box sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}>
            {[
              { key: "email_notifications",  label: "Email Notifications" },
              { key: "system_notifications", label: "System Alerts"       },
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
                <Typography sx={{ fontSize: 13, color: TEXT, fontWeight: 500 }}>
                  {item.label}
                </Typography>
                <Switch
                  checked={formState[item.key] || false}
                  onChange={() => handleToggle(item.key)}
                  sx={{
                    "& .MuiSwitch-switchBase.Mui-checked":                    { color: GOLD },
                    "& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track": { backgroundColor: GOLD, opacity: 0.4 },
                    "& .MuiSwitch-track":                                      { backgroundColor: "rgba(255,255,255,0.15)" },
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
            p: "24px", borderRadius: "18px",
            background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
            border: "1px solid rgba(201,168,76,0.2)",
            position: "relative", overflow: "hidden",
            display: "flex", flexDirection: "column", justifyContent: "center",
          }}
        >
          <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

          <Typography sx={{ ...display, fontSize: 18, fontWeight: 600, color: TEXT, mb: 0.8, fontStyle: "italic" }}>
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
              color: "#000", py: 1.2,
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