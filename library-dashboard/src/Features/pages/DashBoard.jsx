import React, { useEffect, useMemo, useState } from "react";
import {
  Box,
  Typography,
  Button,
  IconButton,
  CircularProgress,
} from "@mui/material";
import { COLORS } from "../../Core/Constants/ColorsUse";
import NotificationsNoneIcon from "@mui/icons-material/NotificationsNone";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import { useDispatch } from "react-redux";

import {
  getDashboardStats,
  getTopBorrowed,
  getWeeklySales,
  getTopSellingBooks,
  getWeeklyBorrows,
} from "../../Core/Redux/Thunks/DashboardThunk";
import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  BarChart,
  Bar,
} from "recharts";

import { useSelector } from "react-redux";

const ADS = [
{
  title: "Discover New Arrivals",
  desc: "Curated collection of newly added premium books",
  img: "https://undraw.co/api/illustrations/digital_library.svg",
},

{
  title: "Reading Performance Boost",
  desc: "Engage users and unlock achievement-based rewards",
  img: "https://undraw.co/api/illustrations/reading.svg",
},

{
  title: "Smart Fee Optimization",
  desc: "Reduce overdue losses with automated discount campaigns",
  img: "https://undraw.co/api/illustrations/finance.svg",
}

];
export default function Dashboard() {
  const [adIndex, setAdIndex] = useState(0);
const dispatch = useDispatch();
useEffect(() => {
  dispatch(getDashboardStats());
  dispatch(getTopBorrowed());
  dispatch(getWeeklySales());
  dispatch(getTopSellingBooks());
  dispatch(getWeeklyBorrows());
}, [dispatch]);
 
const {
  dashboardStats,
   weeklySales,
  topSellingBooks,
  topBorrowedBooks,
  weeklyBorrows,
  loading,
} = useSelector((state) => state.dashboard);
  useEffect(() => {
    const t = setInterval(() => {
      setAdIndex((p) => (p + 1) % ADS.length);
    }, 4500);

    return () => clearInterval(t);
  }, []);

  const currentAd = ADS[adIndex];

  const statsCards = useMemo(() => {
    if (!dashboardStats) return [];

    return [
      {
        title: "Users",
        value: dashboardStats.users || 0,
        mini: [30, 45, 20, 60, 40, 80],
      },
      {
        title: "Books",
        value: dashboardStats.books || 0,
        mini: [20, 35, 50, 40, 70, 60],
      },
      {
        title: "Revenue",
        value: topBorrowedBooks?.total || 0,
        mini: [60, 80, 70, 90, 100, 85],
      },
      {
        title: "Waiting",
        value: topSellingBooks?.length || 0,
        mini: [10, 20, 15, 25, 30, 20],
      },
    ].map((s) => ({
      ...s,
      chartData: s.mini.map((v) => ({ value: v })),
    }));
  }, [dashboardStats, topBorrowedBooks, topSellingBooks]);

  if (loading) {
    return (
      <Box
        sx={{
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          bgcolor: COLORS.bg,
        }}
      >
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box
      sx={{
        minHeight: "100vh",
        bgcolor: COLORS.bg,
        p: { xs: 2, md: 4 },
        fontFamily: "Inter, sans-serif",

        // Sidebar
        ml: { xs: 0, md: "50px" },
        transition: "0.3s",
      }}
    >
      {/* TOP BAR */}
      <Box
        sx={{
          position: "sticky",
          top: 0,
          height: 70,
          px: 3,
          mb: 3,

          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",

          bgcolor: "rgba(255,255,255,0.75)",
          backdropFilter: "blur(12px)",
          borderRadius: 3,
          border: "1px solid rgba(0,0,0,0.05)",
        }}
      >
        <Typography fontWeight={900} color={COLORS.text}>
          Library Dashboard
        </Typography>

        <Box>
          <IconButton>
            <NotificationsNoneIcon />
          </IconButton>
          <IconButton>
            <SettingsOutlinedIcon />
          </IconButton>
        </Box>
      </Box>

      {/* HERO SECTION */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "2fr 1fr" },
          gap: 3,
          mb: 4,
        }}
      >
   <Box
  sx={{
    p: { xs: 3, md: 5 },
    borderRadius: 5,
    color: COLORS.Text,
    background: `
      radial-gradient(circle at top left, rgba(184,160,104,0.25), transparent 45%),
      radial-gradient(circle at bottom right, rgba(49,40,22,0.18), transparent 50%),
      linear-gradient(135deg, ${COLORS.Background}, #f3ece4)
    `,
    boxShadow: "0 25px 60px rgba(49,40,22,0.15)",
    border: "1px solid rgba(184,160,104,0.25)",
    position: "relative",
    overflow: "hidden",
  }}
>
  {/* soft luxury glow */}
  <Box
    sx={{
      position: "absolute",
      top: -80,
      right: -80,
      width: 220,
      height: 220,
      background: `radial-gradient(circle, ${COLORS.Primary}55, transparent 70%)`,
      filter: "blur(25px)",
    }}
  />

  <Typography
    sx={{
      fontSize: { xs: 28, md: 40 },
      fontWeight: 900,
      letterSpacing: -1,
      color: COLORS.Accent,
    }}
  >
    Welcome back
  </Typography>

  <Typography
    sx={{
      fontSize: 18,
      fontWeight: 700,
      mt: 1,
      color: COLORS.Text,
    }}
  >
    Library Operations Center
  </Typography>

  <Typography
    sx={{
      mt: 2,
      maxWidth: 520,
      lineHeight: 1.7,
      fontSize: 15,
      color: COLORS.Text,
      opacity: 0.85,
    }}
  >
    Monitor performance, track engagement, and manage your entire library ecosystem
    from a unified intelligent dashboard designed for clarity and control.
  </Typography>

  <Button
    sx={{
      mt: 4,
      px: 4,
      py: 1.3,
      borderRadius: 3,
      fontWeight: 800,
      textTransform: "none",
      color: "#fff",
      background: `linear-gradient(135deg, ${COLORS.Primary}, ${COLORS.Secondary})`,
      boxShadow: `0 15px 30px ${COLORS.Primary}55`,
      letterSpacing: 0.3,
      "&:hover": {
        background: `linear-gradient(135deg, ${COLORS.Secondary}, ${COLORS.Primary})`,
        transform: "translateY(-3px)",
        boxShadow: `0 20px 40px ${COLORS.Primary}66`,
      },
    }}
  >
    Enter Control Panel →
  </Button>
</Box>

        {/* AD CARD */}
        <Box
         sx={{
  borderRadius: 4,
  bgcolor: "#fff",
  boxShadow: "0 18px 45px rgba(0,0,0,0.08)",
  overflow: "hidden",
  display: "flex",
  flexDirection: "column",
  border: "1px solid rgba(0,0,0,0.05)",
  transition: "0.35s cubic-bezier(.2,.8,.2,1)",
  "&:hover": {
    transform: "translateY(-6px) scale(1.01)",
    boxShadow: "0 25px 60px rgba(0,0,0,0.12)",
  },
}}
        >
          <Box
            sx={{
              height: 240,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              bgcolor: "#faf8f2",
              p: 2,
            }}
          >
            <Box
              component="img"
              src={currentAd.img}
              alt={currentAd.title}
              sx={{
                maxHeight: "100%",
                maxWidth: "100%",
                objectFit: "contain",
              }}
            />
          </Box>

          <Box p={2}>
            <Typography fontWeight={900}>{currentAd.title}</Typography>
            <Typography fontSize={13} opacity={0.7}>
              {currentAd.desc}
            </Typography>
          </Box>
        </Box>
      </Box>

      {/* STATS */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: {
            xs: "1fr",
            sm: "repeat(2,1fr)",
            md: "repeat(4,1fr)",
          },
          gap: 3,
          mb: 4,
        }}
      >
        {statsCards.map((s) => (
          <Box
            key={s.title}
            sx={{
              p: 3,
              borderRadius: 4,
              bgcolor: "#fff",
              boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
              border: "1px solid rgba(0,0,0,0.04)",
              transition: "0.25s",
              "&:hover": {
                transform: "translateY(-6px)",
                boxShadow: "0 18px 35px rgba(0,0,0,0.08)",
              },
            }}
          >
            <Typography fontWeight={700} color={COLORS.text}>
              {s.title}
            </Typography>

            <Typography fontSize={28} fontWeight={900}>
              {Number(s.value).toLocaleString()}
            </Typography>

            <Box height={40} mt={2}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={s.chartData}>
                  <Bar dataKey="value" fill={COLORS.primary} radius={6} />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Box>
        ))}
      </Box>

      {/* CHARTS */}
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "1.4fr 1fr" },
          gap: 3,
        }}
      >
        {/* AREA CHART */}
        <Box
          sx={{
            p: 3,
            borderRadius: 4,
            bgcolor: "#fff",
            boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
          }}
        >
          <Typography fontWeight={900} mb={2}>
            Borrowing Trend
          </Typography>

          <ResponsiveContainer width="100%" height={240}>
            <AreaChart
             data={
  topBorrowedBooks?.map((book, index) => ({
    name: book.title || `Book ${index + 1}`,
    value: book.total || 0,
  })) || []
}
            >
              <XAxis dataKey="name" />
              <YAxis hide />
              <Tooltip />
              <Area
                dataKey="value"
                stroke={COLORS.text}
                fill={COLORS.primary}
                fillOpacity={0.25}
              />
            </AreaChart>
          </ResponsiveContainer>
        </Box>

        {/* TOP BOOKS */}
        <Box
          sx={{
            p: 3,
            borderRadius: 4,
            bgcolor: "#fff",
            boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
          }}
        >
          <Typography fontWeight={900} mb={2}>
            Top Borrowed Books
          </Typography>

          {topBorrowedBooks?.length > 0 ? (
            topBorrowedBooks.map((book, index) => (
              <Box
                key={index}
                sx={{
                  p: 1.5,
                  mb: 1.5,
                  borderRadius: 2,
                  bgcolor: "#f9f7f1",
                  "&:hover": {
                    bgcolor: "#f2efe6",
                    transform: "translateX(3px)",
                  },
                }}
              >
                <Typography fontWeight={700}>
                  📚 {book.title}
                </Typography>
                <Typography fontSize={13} opacity={0.7}>
                  Borrowed {book.total || 0} times
                </Typography>
              </Box>
            ))
          ) : (
            <Typography>No data found</Typography>
          )}
        </Box>
      </Box>

      {/* WAITING LIST */}
      <Box
        sx={{
          mt: 4,
          p: 3,
          borderRadius: 4,
          bgcolor: "#fff",
          boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
        }}
      >
        <Typography fontWeight={900} mb={2}>
          Top Selling Books
        </Typography>

        {topSellingBooks?.length > 0 ? (
          topSellingBooks.map((book, index) => (
            <Box
              key={index}
              sx={{
                py: 1.5,
                px: 2,
                mb: 1.5,
                borderRadius: 2,
                bgcolor: "#f9f7f1",
                "&:hover": {
                  bgcolor: "#f2efe6",
                  transform: "translateX(3px)",
                },
              }}
            >
              <Typography fontWeight={700}>
                � {book.title}
              </Typography>
              <Typography fontSize={13} opacity={0.7}>
                Sold {book.total || 0} times
              </Typography>
            </Box>
          ))
        ) : (
          <Typography>No top selling books</Typography>
        )}
      </Box>
      {/* WEEKLY STATS GRID */}
<Box
  sx={{
    display: "grid",
    gridTemplateColumns: { xs: "1fr", md: "repeat(2,1fr)" },
    gap: 3,
    mt: 3, // مسافة عن الـ Charts اللي فوق
  }}
>
  {/* Weekly Sales */}
  <Box
    sx={{
      p: 3,
      borderRadius: 4,
      bgcolor: "#fff",
      boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
    }}
  >
    <Typography fontWeight={900} mb={2}>
      Weekly Sales
    </Typography>

    {weeklySales?.length > 0 ? (
      <ResponsiveContainer width="100%" height={240}>
        <AreaChart
          data={weeklySales.map((item) => ({
            name: item.week || "Week",
            value: item.total || 0,
          }))}
        >
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Area
            dataKey="value"
            stroke={COLORS.Primary}
            fill={COLORS.Primary}
            fillOpacity={0.25}
          />
        </AreaChart>
      </ResponsiveContainer>
    ) : (
      <Typography>No weekly sales data</Typography>
    )}
  </Box>

  {/* Weekly Borrows */}
  <Box
    sx={{
      p: 3,
      borderRadius: 4,
      bgcolor: "#fff",
      boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
    }}
  >
    <Typography fontWeight={900} mb={2}>
      Weekly Borrows
    </Typography>

    {weeklyBorrows?.length > 0 ? (
      <ResponsiveContainer width="100%" height={240}>
        <AreaChart
          data={weeklyBorrows.map((item) => ({
            name: item.week || "Week",
            value: item.total || 0,
          }))}
        >
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Area
            dataKey="value"
            stroke={COLORS.Secondary}
            fill={COLORS.Secondary}
            fillOpacity={0.25}
          />
        </AreaChart>
      </ResponsiveContainer>
    ) : (
      <Typography>No weekly borrows data</Typography>
    )}
  </Box>
</Box>
    </Box>
  );
}