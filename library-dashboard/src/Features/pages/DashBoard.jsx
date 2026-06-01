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

import { useDashboard } from "../../Core/Context/DashboardContext";



const ADS = [
  {
    title: "New Arrivals",
    desc: "Fresh books added this week",
    img: "https://illustrations.popsy.co/gray/digital-nomad.svg",
  },
  {
    title: "Reading Challenge",
    desc: "Earn rewards while reading",
    img: "https://illustrations.popsy.co/gray/book-lover.svg",
  },
  {
    title: "Fee Discount",
    desc: "Save 50% on overdue fees",
    img: "https://illustrations.popsy.co/gray/savings.svg",
  },
];

export default function Dashboard() {
  const [adIndex, setAdIndex] = useState(0);

  const {
    dashboardStats,
    topBorrowedBooks,
    waitingList,
    totalRevenue,
    loading,
  } = useDashboard();

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
        value: totalRevenue?.total || 0,
        mini: [60, 80, 70, 90, 100, 85],
      },
      {
        title: "Waiting",
        value: waitingList?.length || 0,
        mini: [10, 20, 15, 25, 30, 20],
      },
    ].map((s) => ({
      ...s,
      chartData: s.mini.map((v) => ({ value: v })),
    }));
  }, [dashboardStats, totalRevenue, waitingList]);


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
      }}
    >

      <Box
        sx={{
          position: "fixed",
          top: 0,
          left: 300,
          right: 0,
          height: 70,
          px: 3,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          bgcolor: "rgba(255,255,255,0.8)",
          backdropFilter: "blur(12px)",
          borderBottom: "1px solid rgba(0,0,0,0.05)",
          zIndex: 1000,
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

      <Box height={80} />


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
            p: 4,
            borderRadius: 4,
            color: "#fff",
            background: `linear-gradient(135deg, ${COLORS.dark}, #111827)`,
          }}
        >
          <Typography fontSize={34} fontWeight={900}>
            Welcome back 👋
          </Typography>

          <Typography fontSize={18} fontWeight={600} mt={1}>
            Library Admin
          </Typography>

          <Typography sx={{ opacity: 0.7, mt: 1, maxWidth: 420 }}>
            Everything about your library in one clean analytics view.
          </Typography>

          <Button
            sx={{
              mt: 3,
              bgcolor: COLORS.primary,
              color: "#111",
              fontWeight: 800,
              borderRadius: 3,
              px: 3,

              "&:hover": {
                bgcolor: COLORS.primaryLight,
              },
            }}
          >
            Open Dashboard
          </Button>
        </Box>


        <Box
          sx={{
            borderRadius: 4,
            bgcolor: "#fff",
            boxShadow: "0 12px 30px rgba(0,0,0,0.06)",
            overflow: "hidden",
            display: "flex",
            flexDirection: "column",
          }}
        >
          <Box
            sx={{
              height: 240,
              width: "100%",
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
            <Typography fontWeight={900}>
              {currentAd.title}
            </Typography>

            <Typography fontSize={13} opacity={0.7}>
              {currentAd.desc}
            </Typography>
          </Box>
        </Box>
      </Box>


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
              borderRadius: 3,
              bgcolor: "rgba(255,255,255,0.9)",
              boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
              borderLeft: `4px solid ${COLORS.primary}`,
              transition: "0.25s",

              "&:hover": {
                transform: "translateY(-5px)",
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
                  <Bar
                    dataKey="value"
                    fill={COLORS.primary}
                    radius={6}
                  />
                </BarChart>
              </ResponsiveContainer>
            </Box>
          </Box>
        ))}
      </Box>


      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "1.4fr 1fr" },
          gap: 3,
        }}
      >
       

        <Box
          sx={{
            p: 3,
            borderRadius: 3,
            bgcolor: "#fff",
          }}
        >
          <Typography fontWeight={900} mb={2}>
            Borrowing Trend
          </Typography>

          <ResponsiveContainer width="100%" height={240}>
            <AreaChart
              data={topBorrowedBooks?.map((book, index) => ({
                name: book.title || `Book ${index + 1}`,
                value: book.total || index * 10 + 20,
              }))}
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

     

        <Box
          sx={{
            p: 3,
            borderRadius: 3,
            bgcolor: "#fff",
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

      

      <Box
        sx={{
          mt: 4,
          p: 3,
          borderRadius: 3,
          bgcolor: "#fff",
          boxShadow: "0 10px 25px rgba(0,0,0,0.05)",
        }}
      >
        <Typography fontWeight={900} mb={2}>
          Waiting List
        </Typography>

        {waitingList?.length > 0 ? (
          waitingList.map((item, index) => (
            <Box
              key={index}
              sx={{
                py: 1,
                borderBottom: "1px solid rgba(0,0,0,0.05)",
              }}
            >
              <Typography fontWeight={700}>
                👤 {item.user?.name || "Unknown User"}
              </Typography>

              <Typography fontSize={13} opacity={0.7}>
                Waiting for: {item.book?.title || "Unknown Book"}
              </Typography>
            </Box>
          ))
        ) : (
          <Typography>No waiting users</Typography>
        )}
      </Box>
    </Box>
  );
}