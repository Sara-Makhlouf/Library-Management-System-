import React, { useEffect, useMemo, useState } from "react";
import {
  Box,
  Typography,
  Button,
  IconButton,
  CircularProgress,
  Chip,
} from "@mui/material";
import '../../echo'; 
import NotificationsNoneIcon from "@mui/icons-material/NotificationsNone";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import TrendingUpIcon from "@mui/icons-material/TrendingUp";
import LocalLibraryOutlinedIcon from "@mui/icons-material/LocalLibraryOutlined";
import PersonAddAltOutlinedIcon from "@mui/icons-material/PersonAddAltOutlined";
import AutoStoriesOutlinedIcon from "@mui/icons-material/AutoStoriesOutlined";
import StarRateRoundedIcon from "@mui/icons-material/StarRateRounded";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import MenuBookOutlinedIcon from "@mui/icons-material/MenuBookOutlined";
import SpaceDashboardOutlinedIcon from "@mui/icons-material/SpaceDashboardOutlined";
import { useDispatch, useSelector } from "react-redux";
import {
  getDashboardStats,
  getWeeklySales,
  getWeeklyBorrows,
} from "../../Core/Redux/Thunks/DashboardThunk";
import { ADS, STAT_META } from "../Utils/dashboardData";


const FONT_IMPORT_ID = "lib-fonts";
const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (document.getElementById(FONT_IMPORT_ID)) return;
  const link = document.createElement("link");
  link.id = FONT_IMPORT_ID;
  link.rel = "stylesheet";
  link.href = FONT_HREF;
  document.head.appendChild(link);
}

const KEYFRAMES = `
  @keyframes fadeSlideUp   { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
  @keyframes fadeSlideDown { from { opacity:0; transform:translateY(-12px); } to { opacity:1; transform:translateY(0); } }
  @keyframes pulseDot      { 0%,100%{opacity:1} 50%{opacity:.35} }
  @keyframes pageTurn      { 0%{transform:rotateY(0deg)} 50%{transform:rotateY(-145deg)} 100%{transform:rotateY(-180deg)} }
  @keyframes slideInLeft   { from{opacity:0;transform:translateX(-8px)} to{opacity:1;transform:translateX(0)} }
  @keyframes slideInRight  { from{opacity:0;transform:translateX(8px)} to{opacity:1;transform:translateX(0)} }
  @keyframes barGrow       { from{width:0} to{width:var(--target-w)} }
  @keyframes ringPulse     { 0%,100%{box-shadow:0 0 0 0 rgba(201,168,76,.35)} 70%{box-shadow:0 0 0 8px rgba(201,168,76,0)} }
`;

function injectKeyframes() {
  if (document.getElementById("lib-kf")) return;
  const s = document.createElement("style");
  s.id = "lib-kf";
  s.textContent = KEYFRAMES;
  document.head.appendChild(s);
}

const display = { fontFamily: "'Fraunces', serif" };
const mono = { fontFamily: "'IBM Plex Mono', monospace" };

function CategoryBar({ name, count, max, color, delay = 0 }) {
  const pct = max > 0 ? Math.round((count / max) * 100) : 0;
  return (
    <Box sx={{ mb: 1.5 }}>
      <Box sx={{ display: "flex", justifyContent: "space-between", mb: 0.6 }}>
        <Typography sx={{ fontSize: 12.5, color: "rgba(255,255,255,0.75)", fontWeight: 600 }}>
          {name}
        </Typography>
        <Typography sx={{ ...mono, fontSize: 11.5, color: "rgba(255,255,255,0.35)", fontWeight: 600 }}>
          {count}
        </Typography>
      </Box>
      <Box sx={{ height: 5, borderRadius: 3, bgcolor: "rgba(255,255,255,0.05)", overflow: "hidden" }}>
        <Box
          sx={{
            height: "100%",
            borderRadius: 3,
            background: `linear-gradient(90deg, ${color}88, ${color})`,
            "--target-w": `${pct}%`,
            animation: `barGrow .8s ${delay}s cubic-bezier(.25,.8,.25,1) both`,
          }}
        />
      </Box>
    </Box>
  );
}

function StatCard({ title, value, meta, delay = 0 }) {
  return (
    <Box
      sx={{
        p: "18px",
        borderRadius: "20px",
        bgcolor: "#111118",
        border: "1px solid transparent",
        backgroundImage: `linear-gradient(#111118,#111118), linear-gradient(135deg,${meta.accent}28,transparent)`,
        backgroundOrigin: "border-box",
        backgroundClip: "padding-box, border-box",
        position: "relative",
        overflow: "hidden",
        cursor: "pointer",
        animation: `fadeSlideUp .5s ${delay}s ease both`,
        transition: "transform .25s, background-image .25s",
        "&:hover": {
          transform: "translateY(-4px)",
          backgroundImage: `linear-gradient(#151520,#151520), linear-gradient(135deg,${meta.accent}55,transparent)`,
        },
      }}
    >
      <Box
        sx={{
          width: 30, height: 30,
          borderRadius: "9px",
          bgcolor: `${meta.accent}18`,
          color: meta.accent,
          display: "flex", alignItems: "center", justifyContent: "center",
          mb: 1.6,
        }}
      >
        <Box sx={{ fontSize: 14, display: "flex" }}>{meta.icon}</Box>
      </Box>

      <Typography sx={{ fontSize: 10, fontWeight: 600, color: "rgba(255,255,255,.32)", letterSpacing: ".7px", textTransform: "uppercase", mb: 0.6 }}>
        {title}
      </Typography>
      <Typography sx={{ ...display, fontSize: 27, fontWeight: 600, letterSpacing: -0.5, color: "#fff", mb: 0.4 }}>
        {Number(value).toLocaleString()}
      </Typography>
      <Typography sx={{ fontSize: 10.5, color: meta.accent, display: "flex", alignItems: "center", gap: 0.4, fontWeight: 600 }}>
        <TrendingUpIcon sx={{ fontSize: 12 }} /> {meta.trend}
      </Typography>

     
      <Box sx={{ position: "absolute", bottom: 12, right: 14, opacity: 0.55 }}>
        <svg width="48" height="20" viewBox="0 0 48 20" fill="none">
          <path
            d="M1 16 L10 12 L18 14 L26 7 L34 9 L47 2"
            stroke={meta.accent}
            strokeWidth="1.6"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </Box>
    </Box>
  );
}

function UserRow({ user, delay = 0 }) {
  return (
    <Box
      sx={{
        display: "flex", alignItems: "center", gap: 1.2,
        py: 1, px: 0.5,
        borderRadius: "10px",
        animation: `slideInLeft .4s ${delay}s ease both`,
        transition: "background .2s",
        "&:hover": { bgcolor: "rgba(255,255,255,.04)" },
      }}
    >
      <Box
        sx={{
          width: 30, height: 30,
          borderRadius: "9px",
          bgcolor: "rgba(127,119,221,.15)",
          color: "#7f77dd",
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 12, fontWeight: 700, flexShrink: 0,
          ...display,
        }}
      >
        {user.name?.charAt(0) || "?"}
      </Box>
      <Box sx={{ flex: 1, minWidth: 0 }}>
        <Typography sx={{ fontSize: 12.5, fontWeight: 600, color: "#fff", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
          {user.name}
        </Typography>
        <Typography sx={{ fontSize: 10.5, color: "rgba(255,255,255,.28)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
          {user.email}
        </Typography>
      </Box>
      <Typography sx={{ ...mono, fontSize: 9.5, color: "rgba(255,255,255,.2)", flexShrink: 0 }}>
        {user.joined_at || "—"}
      </Typography>
    </Box>
  );
}

const BOOK_SPINE_COLORS = ["#c9a84c", "#7f77dd", "#4ade80", "#f97373", "#38bdf8", "#fb923c", "#e879f9"];

function BookRow({ book, index, delay = 0 }) {
  const spineColor = BOOK_SPINE_COLORS[index % BOOK_SPINE_COLORS.length];
  return (
    <Box
      sx={{
        display: "flex", alignItems: "center", gap: 1.2,
        py: 1, px: 0.5,
        borderRadius: "10px",
        animation: `slideInRight .4s ${delay}s ease both`,
        transition: "background .2s",
        "&:hover": { bgcolor: "rgba(255,255,255,.04)" },
      }}
    >
      <Box sx={{ width: 5, alignSelf: "stretch", minHeight: 32, borderRadius: "2px 0 0 2px", bgcolor: `${spineColor}66`, flexShrink: 0 }} />
      <Box sx={{ flex: 1, minWidth: 0 }}>
        <Typography sx={{ ...display, fontSize: 13, fontWeight: 600, color: "#fff", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }} title={book.title}>
          {book.title}
        </Typography>
        <Typography sx={{ fontSize: 10.5, color: "rgba(255,255,255,.28)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
          {book.authors?.join(", ") || "Unknown author"}
        </Typography>
      </Box>
      {book.average_rate > 0 && (
        <Box sx={{ display: "flex", alignItems: "center", gap: 0.3, flexShrink: 0 }}>
          <StarRateRoundedIcon sx={{ fontSize: 13, color: "#c9a84c" }} />
          <Typography sx={{ ...mono, fontSize: 11, color: "rgba(255,255,255,.4)", fontWeight: 600 }}>
            {book.average_rate}
          </Typography>
        </Box>
      )}
      <Typography sx={{ ...mono, fontSize: 11.5, color: "#c9a84c", fontWeight: 600, flexShrink: 0, minWidth: 56, textAlign: "right" }}>
        {Number(book.sale_price).toLocaleString()}
      </Typography>
    </Box>
  );
}

function AdCard({ ad, adIndex }) {
  return (
    <Box
      sx={{
        bgcolor: "#111118",
        border: "1px solid rgba(255,255,255,.06)",
        borderRadius: "22px",
        overflow: "hidden",
        display: "flex", flexDirection: "column",
        transition: "border-color .3s",
        "&:hover": { borderColor: "rgba(201,168,76,.2)" },
      }}
    >
      <Box
        sx={{
          height: 168,
          bgcolor: "rgba(255,255,255,.02)",
          display: "flex", alignItems: "center", justifyContent: "center",
          position: "relative",
          fontSize: 46,
        }}
      >
        {ad.emoji}
      </Box>

      <Box sx={{ p: "14px 16px", flex: 1 }}>
        <Typography sx={{ ...display, fontWeight: 600, fontSize: 14.5, color: "#fff", mb: 0.5 }}>{ad.title}</Typography>
        <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,.38)", lineHeight: 1.5 }}>{ad.desc}</Typography>
      </Box>

      <Box sx={{ display: "flex", justifyContent: "center", gap: "5px", pb: 1.5 }}>
        {ADS.map((_, i) => (
          <Box
            key={i}
            sx={{
              height: 4, borderRadius: "2px",
              width: i === adIndex ? 20 : 8,
              bgcolor: i === adIndex ? "#c9a84c" : "rgba(255,255,255,.14)",
              transition: "all .4s ease",
            }}
          />
        ))}
      </Box>
    </Box>
  );
}

const EXTRA_STAT_META = {
  "Active Members":   { icon: <GroupOutlinedIcon sx={{ fontSize: 15 }} />, accent: "#4ade80", trend: "Currently active" },
  "Current Borrowed": { icon: <MenuBookOutlinedIcon sx={{ fontSize: 15 }} />, accent: "#f97373", trend: "Books out on loan" },
};

export default function Dashboard() {
  const [adIndex, setAdIndex] = useState(0);
  const dispatch = useDispatch();
const [, setNotifications] = useState([]);
    //
    useEffect(() => {
        // تأكد من أن window.Echo قد تم تعريفه من ملف echo.js
        if (window.Echo) {
            // استبدل '1' بـ ID المستخدم الحقيقي (يمكنك جلبه من الـ Redux أو الـ Auth state)
            const userId = 1; 
            
            window.Echo.private(`App.Models.User.${userId}`)
                .notification((notification) => {
                    console.log("إشعار جديد وصل:", notification);
                    
                    // هنا نقوم بتحديث الـ State ليظهر الإشعار فوراً في واجهة المستخدم
                    setNotifications((prev) => [notification, ...prev]);
                    
                });
        }

    }, []);
  useEffect(() => {
    injectFonts();
    injectKeyframes();
    dispatch(getDashboardStats());
    dispatch(getWeeklySales());
    dispatch(getWeeklyBorrows());
  }, [dispatch]);

  const { dashboardStats, loading } = useSelector((state) => state.dashboard);

  useEffect(() => {
    const t = setInterval(() => setAdIndex((p) => (p + 1) % ADS.length), 4500);
    return () => clearInterval(t);
  }, []);

  const statsCards = useMemo(() => {
    if (!dashboardStats) return [];
    return [
      { title: "Users",           value: dashboardStats.counts.total_customers },
      { title: "Books",           value: dashboardStats.counts.total_books },
      { title: "Revenue",         value: dashboardStats.counts.total_revenue },
      { title: "Categories",      value: dashboardStats.counts.total_categories },
      { title: "Active Members",  value: dashboardStats.counts.active_members },
      { title: "Current Borrowed",value: dashboardStats.counts.current_borrowed },
    ];
  }, [dashboardStats]);

  const booksPerCategory = dashboardStats?.books_per_category || [];
  const recentUsers      = dashboardStats?.recent_users || [];
  const latestBooks      = dashboardStats?.latest_books || [];

 const maxCategoryCount = useMemo(() => {
  const categories = dashboardStats?.books_per_category ?? [];

  return categories.reduce(
    (m, c) => Math.max(m, c.count || 0),
    0
  );
}, [dashboardStats?.books_per_category]);

  const categoryColors = ["#c9a84c", "#7f77dd", "#4ade80", "#f97373", "#38bdf8", "#fb923c", "#e879f9"];

  const currentAd = ADS[adIndex];

  if (loading) {
    return (
      <Box sx={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", bgcolor: "#0a0a0f" }}>
        <CircularProgress sx={{ color: "#c9a84c" }} />
      </Box>
    );
  }

  return (
    <Box
      sx={{
        minHeight: "100vh",
        bgcolor: "#0a0a0f",
        p: { xs: 2, md: "20px 24px" },
        fontFamily: "Inter, sans-serif",
        animation: "fadeSlideDown .45s ease both",
      }}
    >
      <Box
        sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          mb: 2.5, px: "18px", height: 58,
          bgcolor: "rgba(255,255,255,.04)",
          border: "1px solid rgba(255,255,255,.07)",
          borderRadius: "22px",
          position: "sticky", top: 0, zIndex: 10,
          backdropFilter: "blur(16px)",
          animation: "fadeSlideDown .4s ease both",
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.4 }}>
         
          <Box sx={{ width: 36, height: 36, position: "relative", perspective: "120px", flexShrink: 0 }}>
            <Box
              sx={{
                position: "absolute", inset: 0,
                borderRadius: "8px",
                background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
                display: "flex", alignItems: "center", justifyContent: "center",
              }}
            >
              <Box sx={{ width: 1, height: 22, bgcolor: "rgba(10,10,15,.35)" }} />
            </Box>
            <Box
              sx={{
                position: "absolute", top: 0, left: "50%",
                width: "50%", height: "100%",
                borderRadius: "0 8px 8px 0",
                background: "linear-gradient(135deg,#e3c876,#c9a84c)",
                transformOrigin: "0% 50%",
                animation: "pageTurn 5s ease-in-out infinite",
              }}
            />
          </Box>
          <Box>
            <Typography sx={{ ...display, fontWeight: 600, fontSize: 16, color: "#fff", letterSpacing: -.2, lineHeight: 1.1 }}>
              Hiber &amp; Waraq
            </Typography>
            <Typography sx={{ fontSize: 9.5, color: "rgba(255,255,255,.32)", letterSpacing: ".6px", textTransform: "uppercase", fontWeight: 600 }}>
              Library Dashboard
            </Typography>
          </Box>
        </Box>

        <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
          {[<NotificationsNoneIcon sx={{ fontSize: 17 }} />, <SettingsOutlinedIcon sx={{ fontSize: 17 }} />].map((icon, i) => (
            <IconButton
              key={i}
              sx={{
                width: 32, height: 32,
                borderRadius: "50%",
                bgcolor: "rgba(255,255,255,.06)",
                border: "1px solid rgba(255,255,255,.07)",
                color: "#888",
                "&:hover": { bgcolor: "rgba(255,255,255,.12)", color: "#fff" },
                transition: "all .2s",
              }}
            >
              {icon}
            </IconButton>
          ))}
          <Box
            sx={{
              width: 32, height: 32,
              borderRadius: "50%",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 11, fontWeight: 700, color: "#fff",
              ...display,
              animation: "ringPulse 2.5s ease infinite",
              ml: 0.5, cursor: "pointer",
            }}
          >
            AD
          </Box>
        </Box>
      </Box>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "1fr 280px" },
          gap: 2, mb: 2.5,
          animation: "fadeSlideUp .5s .1s ease both",
        }}
      >
        <Box
          sx={{
            p: { xs: 3, md: "36px 40px" },
            borderRadius: "26px",
            background: "#111118",
            border: "1px solid rgba(201,168,76,.15)",
            position: "relative",
            overflow: "hidden",
          }}
        >
          <Box sx={{ position: "absolute", top: -80, right: -60, width: 280, height: 280, background: "radial-gradient(circle,rgba(201,168,76,.1) 0%,transparent 70%)", pointerEvents: "none" }} />

          <Chip
            label="● Live System"
            size="small"
            sx={{
              mb: 2.5,
              bgcolor: "rgba(201,168,76,.1)",
              border: "1px solid rgba(201,168,76,.2)",
              color: "#c9a84c",
              fontWeight: 600, fontSize: 11, letterSpacing: .5,
              height: 24, borderRadius: "20px",
              "& .MuiChip-label": { px: 1.5, display: "flex", alignItems: "center", gap: "5px" },
            }}
          />

          <Typography
            sx={{
              ...display,
              fontSize: { xs: 28, md: 38 },
              fontWeight: 600, letterSpacing: -0.5, lineHeight: 1.08,
              mb: 1.5,
              color: "#fff",
            }}
          >
            Welcome back,<br />
            <Box component="span" sx={{ color: "#c9a84c", fontStyle: "italic" }}>Library Admin</Box>
          </Typography>

          <Typography sx={{ fontSize: 13.5, color: "rgba(255,255,255,.45)", lineHeight: 1.7, maxWidth: 400, mb: 3.5 }}>
            Monitor performance, track engagement, and manage your entire library
            ecosystem from a unified intelligent dashboard.
          </Typography>

          <Button
            endIcon={<SpaceDashboardOutlinedIcon sx={{ fontSize: 15 }} />}
            sx={{
              px: 3, py: 1.2,
              borderRadius: "12px",
              fontWeight: 700, textTransform: "none", fontSize: 13.5,
              color: "#fff",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              letterSpacing: .2,
              "&:hover": {
                background: "linear-gradient(135deg,#d4b562,#9e6c20)",
                transform: "translateY(-2px)",
                boxShadow: "0 14px 28px rgba(201,168,76,.25)",
              },
              transition: "all .25s",
            }}
          >
            Enter Control Panel
          </Button>
        </Box>

        <AdCard ad={currentAd} adIndex={adIndex} />
      </Box>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr 1fr", sm: "repeat(3,1fr)", md: "repeat(6,1fr)" },
          gap: 2, mb: 2.5,
        }}
      >
        {statsCards.map((s, i) => {
          const meta = STAT_META[s.title] || EXTRA_STAT_META[s.title] || { icon: null, accent: "#888", trend: "" };
          return <StatCard key={s.title} title={s.title} value={s.value} meta={meta} delay={0.2 + i * 0.05} />;
        })}
      </Box>

      <Box
        sx={{
          p: { xs: 2.5, md: "24px 26px" },
          borderRadius: "26px",
          bgcolor: "#111118",
          border: "1px solid rgba(255,255,255,.06)",
          position: "relative",
          overflow: "hidden",
          animation: "fadeSlideUp .5s .5s ease both",
        }}
      >
        <Box sx={{ position: "absolute", top: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,.45),transparent)" }} />

        <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 3 }}>
          <Box>
            <Typography sx={{ ...display, fontSize: 16.5, fontWeight: 600, color: "#fff", letterSpacing: -.2 }}>Library Insights</Typography>
            <Typography sx={{ fontSize: 11.5, color: "rgba(255,255,255,.3)", mt: 0.3 }}>Categories, new members, and latest additions</Typography>
          </Box>
          <Chip
            label="● Live"
            size="small"
            sx={{
              bgcolor: "rgba(74,222,128,.1)", color: "#4ade80",
              fontWeight: 700, fontSize: 10.5, letterSpacing: .5,
              height: 22, borderRadius: "20px",
              "& .MuiChip-label": { px: 1.2, display: "flex", alignItems: "center", gap: "4px" },
            }}
          />
        </Box>

        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", md: "1fr 1fr 1.2fr" }, gap: 3 }}>

          <Box>
            <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 2 }}>
              <Box sx={{ width: 26, height: 26, borderRadius: "8px", bgcolor: "rgba(201,168,76,.12)", color: "#c9a84c", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <LocalLibraryOutlinedIcon sx={{ fontSize: 14 }} />
              </Box>
              <Typography sx={{ fontSize: 11.5, fontWeight: 700, color: "rgba(255,255,255,.55)", letterSpacing: .3 }}>Books per Category</Typography>
            </Box>
            {booksPerCategory.length > 0
              ? booksPerCategory.map((cat, i) => (
                  <CategoryBar
                    key={cat.name}
                    name={cat.name}
                    count={cat.count}
                    max={maxCategoryCount}
                    color={categoryColors[i % categoryColors.length]}
                    delay={0.6 + i * 0.06}
                  />
                ))
              : <Typography sx={{ color: "rgba(255,255,255,.2)", fontSize: 12.5 }}>No categories yet</Typography>
            }
          </Box>

          <Box>
            <Box sx={{ display: "flex", alignItems: "center", gap: 1, mb: 2 }}>
              <Box sx={{ width: 26, height: 26, borderRadius: "8px", bgcolor: "rgba(127,119,221,.12)", color: "#7f77dd", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <PersonAddAltOutlinedIcon sx={{ fontSize: 14 }} />
              </Box>
              <Typography sx={{ fontSize: 11.5, fontWeight: 700, color: "rgba(255,255,255,.55)", letterSpacing: .3 }}>Recent Members</Typography>
            </Box>
            {recentUsers.length > 0
              ? recentUsers.map((u, i) => <UserRow key={u.id} user={u} delay={0.65 + i * 0.08} />)
              : <Typography sx={{ color: "rgba(255,255,255,.2)", fontSize: 12.5 }}>No recent members</Typography>
            }
          </Box>

          <Box>
            <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2 }}>
              <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
                <Box sx={{ width: 26, height: 26, borderRadius: "8px", bgcolor: "rgba(74,222,128,.12)", color: "#4ade80", display: "flex", alignItems: "center", justifyContent: "center" }}>
                  <AutoStoriesOutlinedIcon sx={{ fontSize: 14 }} />
                </Box>
                <Typography sx={{ fontSize: 11.5, fontWeight: 700, color: "rgba(255,255,255,.55)", letterSpacing: .3 }}>Latest Books</Typography>
              </Box>
              <Typography sx={{ fontSize: 11, color: "#c9a84c", fontWeight: 600, cursor: "pointer" }}>View all →</Typography>
            </Box>
            {latestBooks.length > 0
              ? latestBooks.map((book, i) => <BookRow key={book.id} book={book} index={i} delay={0.7 + i * 0.08} />)
              : <Typography sx={{ color: "rgba(255,255,255,.2)", fontSize: 12.5 }}>No books yet</Typography>
            }
          </Box>

        </Box>
      </Box>
    </Box>
  );
}