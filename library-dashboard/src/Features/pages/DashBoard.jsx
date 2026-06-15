import React, { useEffect, useMemo, useState } from "react";
import {
  Box,
  Typography,
  Button,
  IconButton,
  CircularProgress,
  Chip,
} from "@mui/material";
import NotificationsNoneIcon from "@mui/icons-material/NotificationsNone";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import TrendingUpIcon from "@mui/icons-material/TrendingUp";
import PeopleAltOutlinedIcon from "@mui/icons-material/PeopleAltOutlined";
import MenuBookOutlinedIcon from "@mui/icons-material/MenuBookOutlined";
import AttachMoneyIcon from "@mui/icons-material/AttachMoney";
import CategoryOutlinedIcon from "@mui/icons-material/CategoryOutlined";
import SpaceDashboardOutlinedIcon from "@mui/icons-material/SpaceDashboardOutlined";
import { useDispatch, useSelector } from "react-redux";
import {
  getDashboardStats,
  getWeeklySales,
  getTopSellingBooks,
  getWeeklyBorrows,
} from "../../Core/Redux/Thunks/DashboardThunk";
import {
  ResponsiveContainer,

  AreaChart,
  Area,
} from "recharts";


const ADS = [
  {
    emoji: "📖",
    title: "Discover New Arrivals",
    desc: "Curated collection of newly added premium books",
  },
  {
    emoji: "🏆",
    title: "Reading Performance Boost",
    desc: "Engage users and unlock achievement-based rewards",
  },
  {
    emoji: "💡",
    title: "Smart Fee Optimization",
    desc: "Reduce overdue losses with automated discount campaigns",
  },
];

const STAT_META = {
  Users:      { icon: <PeopleAltOutlinedIcon sx={{ fontSize: 16 }} />, accent: "#c9a84c", trend: "+12% this week" },
  Books:      { icon: <MenuBookOutlinedIcon  sx={{ fontSize: 16 }} />, accent: "#97c459", trend: "+8% this month" },
  Revenue:    { icon: <AttachMoneyIcon       sx={{ fontSize: 16 }} />, accent: "#1d9e75", trend: "+23% vs last month" },
  Categories: { icon: <CategoryOutlinedIcon  sx={{ fontSize: 16 }} />, accent: "#7f77dd", trend: "3 new added" },
};

const CHART_DATA = [8, 14, 10, 20, 26, 18, 30].map((v) => ({ v }));


function MiniChart({ color }) {
  return (
    <Box sx={{ height: 32, mt: 1.5 }}>
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={CHART_DATA}>
          <defs>
            <linearGradient id={`g${color.replace("#", "")}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={color} stopOpacity={0.25} />
              <stop offset="100%" stopColor={color} stopOpacity={0} />
            </linearGradient>
          </defs>
          <Area
            type="monotone"
            dataKey="v"
            stroke={color}
            strokeWidth={1.5}
            fill={`url(#g${color.replace("#", "")})`}
            dot={false}
          />
        </AreaChart>
      </ResponsiveContainer>
    </Box>
  );
}

function WeeklyBar({ data, color }) {
  const max = Math.max(...data);
  return (
    <Box sx={{ display: "flex", alignItems: "flex-end", gap: "3px", height: 50, mt: 2.5 }}>
      {data.map((v, i) => (
        <Box
          key={i}
          sx={{
            flex: 1,
            borderRadius: "3px 3px 0 0",
            background: `linear-gradient(180deg, ${color}, ${color}30)`,
            height: `${Math.round((v / max) * 100)}%`,
            minHeight: 3,
            transition: "height 0.5s ease",
          }}
        />
      ))}
    </Box>
  );
}


export default function Dashboard() {
  const [adIndex, setAdIndex] = useState(0);
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(getDashboardStats());
    dispatch(getWeeklySales());
    dispatch(getTopSellingBooks());
    dispatch(getWeeklyBorrows());
  }, [dispatch]);

  const { dashboardStats, weeklySales, topSellingBooks, weeklyBorrows, loading } =
    useSelector((state) => state.dashboard);

  useEffect(() => {
    const t = setInterval(() => setAdIndex((p) => (p + 1) % ADS.length), 4500);
    return () => clearInterval(t);
  }, []);

  const statsCards = useMemo(() => {
    if (!dashboardStats) return [];
    return [
      { title: "Users",      value: dashboardStats.counts.total_customers },
      { title: "Books",      value: dashboardStats.counts.total_books },
      { title: "Revenue",    value: dashboardStats.counts.total_revenue },
      { title: "Categories", value: dashboardStats.counts.total_categories },
    ];
  }, [dashboardStats]);

  const currentAd = ADS[adIndex];
  const salesBars  = [30, 45, 35, 60, 50, 70, 55];
  const borrowBars = [20, 35, 28, 42, 38, 55, 44];

  if (loading) {
    return (
      <Box
        sx={{
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          bgcolor: "#0a0a0f",
        }}
      >
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
        ml: { xs: 0, },
        fontFamily: "Inter, sans-serif",
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          mb: 3,
          px: "20px",
          height: 60,
          bgcolor: "rgba(255,255,255,0.04)",
          border: "1px solid rgba(255,255,255,0.08)",
          borderRadius: "16px",
          position: "sticky",
          top: 0,
          zIndex: 10,
          backdropFilter: "blur(16px)",
        }}
      >
        <Box sx={{ display: "flex", alignItems: "center", gap: 1.5 }}>
          <Box
            sx={{
              width: 32,
              height: 32,
              borderRadius: "10px",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 16,
            }}
          >
            📚
          </Box>
          <Typography sx={{ fontWeight: 700, fontSize: 15, color: "#fff", letterSpacing: -0.3 }}>
            Library Dashboard
          </Typography>
        </Box>

        <Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
          {[<NotificationsNoneIcon sx={{ fontSize: 18 }} />, <SettingsOutlinedIcon sx={{ fontSize: 18 }} />].map(
            (icon, i) => (
              <IconButton
                key={i}
                sx={{
                  width: 34,
                  height: 34,
                  borderRadius: "10px",
                  bgcolor: "rgba(255,255,255,0.06)",
                  color: "#888",
                  "&:hover": { bgcolor: "rgba(255,255,255,0.1)", color: "#fff" },
                  transition: "all 0.2s",
                }}
              >
                {icon}
              </IconButton>
            )
          )}
          <Box
            sx={{
              width: 34,
              height: 34,
              borderRadius: "10px",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 12,
              fontWeight: 700,
              color: "#fff",
              ml: 0.5,
            }}
          >
            AD
          </Box>
        </Box>
      </Box>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "1fr 300px" },
          gap: 2,
          mb: 2.5,
        }}
      >
       
        <Box
          sx={{
            p: { xs: 3, md: "36px 40px" },
            borderRadius: "20px",
            background: "linear-gradient(135deg,#111118 0%,#1a1206 100%)",
            border: "1px solid rgba(201,168,76,0.2)",
            position: "relative",
            overflow: "hidden",
          }}
        >
          <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.08) 0%,transparent 70%)", pointerEvents: "none" }} />
          <Box sx={{ position: "absolute", bottom: -60, left: -40, width: 200, height: 200, background: "radial-gradient(circle,rgba(139,94,26,0.06) 0%,transparent 70%)", pointerEvents: "none" }} />
          <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

          <Chip
            label="● Live System"
            size="small"
            sx={{
              mb: 2.5,
              bgcolor: "rgba(201,168,76,0.1)",
              border: "1px solid rgba(201,168,76,0.2)",
              color: "#c9a84c",
              fontWeight: 600,
              fontSize: 11,
              letterSpacing: 0.5,
              height: 24,
              borderRadius: "20px",
              "& .MuiChip-label": { px: 1.5 },
            }}
          />

          <Typography
            sx={{
              fontSize: { xs: 26, md: 34 },
              fontWeight: 800,
              letterSpacing: -1,
              lineHeight: 1.1,
              mb: 1.5,
              background: "linear-gradient(135deg,#fff 0%,#c9a84c 100%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
              backgroundClip: "text",
            }}
          >
            Welcome back,<br />Library Admin
          </Typography>

          <Typography sx={{ fontSize: 14, color: "rgba(255,255,255,0.45)", lineHeight: 1.7, maxWidth: 420, mb: 3.5 }}>
            Monitor performance, track engagement, and manage your entire library
            ecosystem from a unified intelligent dashboard.
          </Typography>

          <Button
            endIcon={<SpaceDashboardOutlinedIcon sx={{ fontSize: 15 }} />}
            sx={{
              px: 3,
              py: 1.2,
              borderRadius: "12px",
              fontWeight: 700,
              textTransform: "none",
              fontSize: 13.5,
              color: "#fff",
              background: "linear-gradient(135deg,#c9a84c,#8b5e1a)",
              letterSpacing: 0.2,
              "&:hover": {
                background: "linear-gradient(135deg,#d4b562,#9e6c20)",
                transform: "translateY(-2px)",
                boxShadow: "0 16px 32px rgba(201,168,76,0.25)",
              },
              transition: "all 0.25s",
            }}
          >
            Enter Control Panel
          </Button>
        </Box>

        <Box
          sx={{
            bgcolor: "#111118",
            border: "1px solid rgba(255,255,255,0.06)",
            borderRadius: "20px",
            overflow: "hidden",
            display: "flex",
            flexDirection: "column",
            transition: "border-color 0.3s",
            "&:hover": { borderColor: "rgba(201,168,76,0.2)" },
          }}
        >
          <Box
            sx={{
              height: 180,
              bgcolor: "rgba(255,255,255,0.02)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 52,
            }}
          >
            {currentAd.emoji}
          </Box>
          <Box sx={{ p: "16px 18px", flex: 1 }}>
            <Typography sx={{ fontWeight: 700, fontSize: 13.5, color: "#fff", mb: 0.5 }}>
              {currentAd.title}
            </Typography>
            <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.4)", lineHeight: 1.5 }}>
              {currentAd.desc}
            </Typography>
          </Box>
          <Box sx={{ display: "flex", justifyContent: "center", gap: "6px", pb: 1.5 }}>
            {ADS.map((_, i) => (
              <Box
                key={i}
                sx={{
                  height: 4,
                  borderRadius: "2px",
                  width: i === adIndex ? 20 : 4,
                  bgcolor: i === adIndex ? "#c9a84c" : "rgba(255,255,255,0.15)",
                  transition: "all 0.4s ease",
                }}
              />
            ))}
          </Box>
        </Box>
      </Box>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr 1fr", md: "repeat(4,1fr)" },
          gap: 2,
          mb: 2.5,
        }}
      >
        {statsCards.map((s) => {
          const meta = STAT_META[s.title] || { icon: null, accent: "#888", trend: "" };
          return (
            <Box
              key={s.title}
              sx={{
                p: "20px",
                borderRadius: "18px",
                bgcolor: "#111118",
                border: "1px solid rgba(255,255,255,0.06)",
                position: "relative",
                overflow: "hidden",
                cursor: "pointer",
                transition: "all 0.25s",
                "&:hover": {
                  borderColor: `${meta.accent}40`,
                  transform: "translateY(-3px)",
                  bgcolor: "#151520",
                },
              }}
            >
              <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 1.5 }}>
                <Typography sx={{ fontSize: 11, fontWeight: 600, color: "rgba(255,255,255,0.35)", letterSpacing: "0.8px", textTransform: "uppercase" }}>
                  {s.title}
                </Typography>
                <Box
                  sx={{
                    width: 28,
                    height: 28,
                    borderRadius: "8px",
                    bgcolor: `${meta.accent}18`,
                    color: meta.accent,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  }}
                >
                  {meta.icon}
                </Box>
              </Box>
              <Typography sx={{ fontSize: 28, fontWeight: 800, letterSpacing: -1, color: "#fff", mb: 0.5 }}>
                {Number(s.value).toLocaleString()}
              </Typography>
              <Typography sx={{ fontSize: 11, color: meta.accent, display: "flex", alignItems: "center", gap: 0.3 }}>
                <TrendingUpIcon sx={{ fontSize: 12 }} /> {meta.trend}
              </Typography>
              <MiniChart color={meta.accent} />
            </Box>
          );
        })}
      </Box>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "1fr 1fr 1.4fr" },
          gap: 2,
        }}
      >
        <Box
          sx={{
            p: "20px",
            borderRadius: "18px",
            bgcolor: "#111118",
            border: "1px solid rgba(255,255,255,0.06)",
            position: "relative",
            overflow: "hidden",
          }}
        >
          <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />
          <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2 }}>
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
              Weekly Sales
            </Typography>
            <Box sx={{ px: 1.2, py: 0.3, borderRadius: "6px", bgcolor: "rgba(74,222,128,0.1)" }}>
              <Typography sx={{ fontSize: 10, fontWeight: 700, color: "#4ade80", letterSpacing: 0.5 }}>↑ LIVE</Typography>
            </Box>
          </Box>
          <Typography sx={{ fontSize: 26, fontWeight: 800, letterSpacing: -0.5, color: "#c9a84c", mb: 0.5 }}>
            {weeklySales?.total_revenue || "0 SYP"}
          </Typography>
          <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
            {weeklySales?.total_orders || 0} orders this week
          </Typography>
          <WeeklyBar data={salesBars} color="#c9a84c" />
        </Box>

        <Box
          sx={{
            p: "20px",
            borderRadius: "18px",
            bgcolor: "#111118",
            border: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2 }}>
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
              Weekly Borrows
            </Typography>
            <Box sx={{ px: 1.2, py: 0.3, borderRadius: "6px", bgcolor: "rgba(127,119,221,0.1)" }}>
              <Typography sx={{ fontSize: 10, fontWeight: 700, color: "#7f77dd", letterSpacing: 0.5 }}>Books</Typography>
            </Box>
          </Box>
          <Typography sx={{ fontSize: 26, fontWeight: 800, letterSpacing: -0.5, color: "#7f77dd", mb: 0.5 }}>
            {weeklyBorrows?.total_borrows || 0}
          </Typography>
          <Typography sx={{ fontSize: 12, color: "rgba(255,255,255,0.3)" }}>
            Total borrowed items
          </Typography>
          <WeeklyBar data={borrowBars} color="#7f77dd" />
        </Box>

        <Box
          sx={{
            p: "20px",
            borderRadius: "18px",
            bgcolor: "#111118",
            border: "1px solid rgba(255,255,255,0.06)",
          }}
        >
          <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", mb: 2.5 }}>
            <Typography sx={{ fontSize: 13, fontWeight: 700, color: "rgba(255,255,255,0.6)", letterSpacing: 0.3 }}>
              Top Selling Books
            </Typography>
            <Typography sx={{ fontSize: 11, color: "#c9a84c", fontWeight: 600, cursor: "pointer" }}>
              View all →
            </Typography>
          </Box>

          {topSellingBooks?.length > 0 ? (
            topSellingBooks.map((book, i) => {
              const pct = Math.round(((book.units_sold || 0) / (topSellingBooks[0]?.units_sold || 1)) * 100);
              return (
                <Box
                  key={i}
                  sx={{
                    display: "flex",
                    alignItems: "center",
                    gap: 1.5,
                    py: 1.2,
                    px: 1,
                    borderRadius: "10px",
                    mb: 0.5,
                    transition: "all 0.2s",
                    "&:hover": { bgcolor: "rgba(255,255,255,0.04)" },
                    cursor: "pointer",
                  }}
                >
                  <Box
                    sx={{
                      minWidth: 26,
                      height: 26,
                      borderRadius: "7px",
                      bgcolor: i === 0 ? "rgba(201,168,76,0.15)" : "rgba(255,255,255,0.05)",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      fontSize: 11,
                      fontWeight: 800,
                      color: i === 0 ? "#c9a84c" : "rgba(255,255,255,0.2)",
                    }}
                  >
                    {i + 1}
                  </Box>
                  <Box sx={{ flex: 1, minWidth: 0 }}>
                    <Typography sx={{ fontWeight: 600, fontSize: 13, color: "#fff", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                      {book.book_title}
                    </Typography>
                    <Typography sx={{ fontSize: 11, color: "rgba(255,255,255,0.3)" }}>
                      {book.units_sold || 0} sold
                    </Typography>
                  </Box>
                  <Box sx={{ width: 50 }}>
                    <Box sx={{ height: 3, borderRadius: 2, bgcolor: "rgba(255,255,255,0.07)", overflow: "hidden" }}>
                      <Box sx={{ height: "100%", width: `${pct}%`, bgcolor: i === 0 ? "#c9a84c" : "rgba(255,255,255,0.2)", borderRadius: 2 }} />
                    </Box>
                  </Box>
                </Box>
              );
            })
          ) : (
            <Box sx={{ py: 4, textAlign: "center" }}>
              <Typography sx={{ color: "rgba(255,255,255,0.2)", fontSize: 13 }}>No top selling books yet</Typography>
            </Box>
          )}
        </Box>
      </Box>
    </Box>
  );
}