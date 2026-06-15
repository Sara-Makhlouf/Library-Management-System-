import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, Chip, CircularProgress } from "@mui/material";
import { motion } from "framer-motion";
import { Users, Award, Phone, UserCircle } from "lucide-react";

import { fetchUsers, getAllOperationForUser } from "../../Core/Redux/Thunks/UserThunk";

const BG      = "#0a0a0f";
const SURFACE = "#111118";
const GOLD    = "#c9a84c";
const GOLD2   = "#8b5e1a";
const BORDER  = "rgba(255,255,255,0.06)";
const TEXT    = "#fff";
const MUTED   = "rgba(255,255,255,0.35)";

function ProfileCard({ profile }) {
  return (
    <Box
      component={motion.div}
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      sx={{
        p: "20px", borderRadius: "18px",
        bgcolor: SURFACE, border: `1px solid ${BORDER}`,
        transition: "all 0.25s",
        "&:hover": { borderColor: `${GOLD}40`, transform: "translateY(-2px)", bgcolor: "#151520" },
      }}
    >
      <Box sx={{ display: "flex", alignItems: "center", gap: 1.5, mb: 2 }}>
        <Box
          sx={{
            width: 40, height: 40, borderRadius: "12px",
            background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
            display: "flex", alignItems: "center", justifyContent: "center",
            flexShrink: 0,
          }}
        >
          <UserCircle size={20} color="#fff" />
        </Box>
        <Box sx={{ minWidth: 0 }}>
          <Typography sx={{ fontSize: 14, fontWeight: 700, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
            {profile?.name || "—"}
          </Typography>
          {profile?.phone && (
            <Typography sx={{ fontSize: 12, color: MUTED, display: "flex", alignItems: "center", gap: 0.5, mt: 0.2 }}>
              <Phone size={11} /> {profile.phone}
            </Typography>
          )}
        </Box>
      </Box>

      <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", pt: 1.5, borderTop: `1px solid ${BORDER}` }}>
        {profile?.member_type && (
          <Chip
            label={profile.member_type}
            size="small"
            sx={{
              bgcolor: "rgba(201,168,76,0.1)",
              border: "1px solid rgba(201,168,76,0.2)",
              color: GOLD, fontWeight: 700, fontSize: 11,
              height: 24, borderRadius: "8px",
            }}
          />
        )}

        {profile?.points !== undefined && (
          <Box sx={{ display: "flex", alignItems: "center", gap: 0.5 }}>
            <Award size={14} color="#97c459" />
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "#97c459" }}>
              {profile.points} pts
            </Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}

export default function UserProfilePage() {
  const dispatch = useDispatch();
  const { users, loading } = useSelector((state) => state.user);

  const [profiles, setProfiles] = useState([]);
  const [profilesLoading, setProfilesLoading] = useState(false);

  useEffect(() => {
    dispatch(fetchUsers());
  }, [dispatch]);

  useEffect(() => {
    if (!users || users.length === 0) return;

    let cancelled = false;

    const loadProfiles = async () => {
      setProfilesLoading(true);
      const results = [];

      for (const user of users) {
        try {
          const res = await dispatch(getAllOperationForUser(user.id)).unwrap();
          results.push({ id: user.id, ...res.data });
        } catch (err) {
          console.error(`Failed to load profile for user ${user.id}:`, err);
        }
      }

      if (!cancelled) {
        setProfiles(results);
        setProfilesLoading(false);
      }
    };

    loadProfiles();

    return () => { cancelled = true; };
  }, [users, dispatch]);

  const isLoading = loading || profilesLoading;

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
            <Users size={17} color="#fff" />
          </Box>
          <Typography sx={{ fontWeight: 700, fontSize: 15, color: TEXT, letterSpacing: -0.3 }}>
            User Profiles
          </Typography>
        </Box>

        <Chip
          label={`${profiles.length} loaded`}
          sx={{
            bgcolor: "rgba(201,168,76,0.1)",
            border: "1px solid rgba(201,168,76,0.2)",
            color: GOLD, fontWeight: 700, fontSize: 11.5,
            letterSpacing: 0.3, height: 28, borderRadius: "8px",
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
          label="● Community"
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
          All member profiles
        </Typography>

        <Typography sx={{ fontSize: 14, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 440 }}>
          Browse profile details, membership type, and loyalty points for every registered member.
        </Typography>
      </Box>

      {isLoading && profiles.length === 0 && (
        <Box sx={{ display: "flex", justifyContent: "center", py: 6 }}>
          <CircularProgress sx={{ color: GOLD }} />
        </Box>
      )}

      {!isLoading && profiles.length === 0 && (
        <Box sx={{ textAlign: "center", py: 6 }}>
          <Typography sx={{ color: MUTED, fontSize: 13 }}>No profiles found</Typography>
        </Box>
      )}

      {profiles.length > 0 && (
        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "1fr 1fr", md: "repeat(3,1fr)" }, gap: 2 }}>
          {profiles.map((p) => (
            <ProfileCard key={p.id} profile={p.profile} />
          ))}

          {profilesLoading && (
            <Box sx={{ display: "flex", alignItems: "center", justifyContent: "center", p: "20px", borderRadius: "18px", bgcolor: SURFACE, border: `1px solid ${BORDER}` }}>
              <CircularProgress size={22} sx={{ color: GOLD }} />
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
}