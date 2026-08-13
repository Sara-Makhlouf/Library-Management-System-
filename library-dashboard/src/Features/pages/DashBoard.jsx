import React, {
  memo,
  useEffect,
  useMemo,
  useState,
} from "react";

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
} from "../../Core/Redux/Thunks/DashboardThunk";

import {
  ADS,
  STAT_META,
} from "../Utils/dashboardData";

import {
  GOLD_DARK,
  goldA,
  inkA,
  CARD_BG,
  CARD_BG_HOVER,
  GOLD,
  INK,
  PAGE_BG,
  GOLD_DEEP,
} from "../../Core/Constants/ColorsUse";



const FONT_IMPORT_ID = "lib-fonts";

const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (typeof document === "undefined") return;

  if (document.getElementById(FONT_IMPORT_ID)) {
    return;
  }

  const link = document.createElement("link");

  link.id = FONT_IMPORT_ID;
  link.rel = "stylesheet";
  link.href = FONT_HREF;

  document.head.appendChild(link);
}


const KEYFRAMES = `
  @keyframes fadeSlideUp {
    from {
      opacity: 0;
      transform: translateY(12px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes fadeSlideDown {
    from {
      opacity: 0;
      transform: translateY(-8px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes pageTurn {
    0% {
      transform: rotateY(0deg);
    }

    50% {
      transform: rotateY(-145deg);
    }

    100% {
      transform: rotateY(-180deg);
    }
  }

  @keyframes slideInLeft {
    from {
      opacity: 0;
      transform: translateX(-6px);
    }

    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  @keyframes slideInRight {
    from {
      opacity: 0;
      transform: translateX(6px);
    }

    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  @keyframes barGrow {
    from {
      width: 0;
    }

    to {
      width: var(--target-w);
    }
  }

  @keyframes ringPulse {
    0%,
    100% {
      box-shadow: 0 0 0 0 rgba(201, 168, 76, 0.2);
    }

    70% {
      box-shadow: 0 0 0 6px rgba(201, 168, 76, 0);
    }
  }

  @keyframes floatBlobA {
    0%,
    100% {
      transform: translate(0, 0);
    }

    50% {
      transform: translate(20px, -16px);
    }
  }

  @keyframes floatBlobB {
    0%,
    100% {
      transform: translate(0, 0);
    }

    50% {
      transform: translate(-18px, 14px);
    }
  }

  @keyframes shimmerSweep {
    0% {
      background-position: -200% 0;
    }

    100% {
      background-position: 200% 0;
    }
  }

  @keyframes iconGlow {
    0%,
    100% {
      filter: drop-shadow(0 0 0 rgba(201, 168, 76, 0));
    }

    50% {
      filter: drop-shadow(0 0 4px rgba(201, 168, 76, 0.4));
    }
  }

  @media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
      scroll-behavior: auto !important;
    }
  }
`;

function injectKeyframes() {
  if (typeof document === "undefined") return;

  if (document.getElementById("lib-kf")) {
    return;
  }

  const style = document.createElement("style");

  style.id = "lib-kf";
  style.textContent = KEYFRAMES;

  document.head.appendChild(style);
}



const display = {
  fontFamily: "'Fraunces', serif",
};

const mono = {
  fontFamily: "'IBM Plex Mono', monospace",
};

const BOOK_SPINE_COLORS = [
  "#c9a84c",
  "#7f77dd",
  "#3fb873",
  "#e0655f",
  "#2f9fd6",
  "#e08a3c",
  "#cf62c9",
];

const CATEGORY_COLORS = [
  "#c9a84c",
  "#7f77dd",
  "#3fb873",
  "#e0655f",
  "#2f9fd6",
  "#e08a3c",
  "#cf62c9",
];

const EXTRA_STAT_META = {
  "Active Members": {
    icon: <GroupOutlinedIcon sx={{ fontSize: 15 }} />,
    accent: "#3fb873",
    trend: "Currently active",
  },

  "Current Borrowed": {
    icon: <MenuBookOutlinedIcon sx={{ fontSize: 15 }} />,
    accent: "#e0655f",
    trend: "Books out on loan",
  },
};


const CategoryBar = memo(function CategoryBar({
  name,
  count,
  max,
  color,
  delay = 0,
}) {
  const pct =
    max > 0
      ? Math.round((count / max) * 100)
      : 0;

  return (
    <Box sx={{ mb: 1.5 }}>
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          mb: 0.6,
        }}
      >
        <Typography
          sx={{
            fontSize: 12.5,
            color: inkA(0.78),
            fontWeight: 600,
          }}
        >
          {name}
        </Typography>

        <Typography
          sx={{
            ...mono,
            fontSize: 11.5,
            color: inkA(0.42),
            fontWeight: 600,
          }}
        >
          {count}
        </Typography>
      </Box>

      <Box
        sx={{
          height: 5,
          borderRadius: 3,
          bgcolor: goldA(0.1),
          overflow: "hidden",
        }}
      >
        <Box
          sx={{
            height: "100%",
            borderRadius: 3,
            background: `linear-gradient(90deg, ${color}88, ${color})`,
            "--target-w": `${pct}%`,
            animation: `barGrow .7s ${delay}s cubic-bezier(.25,.8,.25,1) both`,
            willChange: "width",
          }}
        />
      </Box>
    </Box>
  );
});



const StatCard = memo(function StatCard({
  title,
  value,
  meta,
  delay = 0,
}) {
  const formattedValue = Number(
    value ?? 0
  ).toLocaleString();

  return (
    <Box
      sx={{
        p: "18px",
        borderRadius: "20px",
        bgcolor: CARD_BG,

        border: "1px solid transparent",

        backgroundImage: `
          linear-gradient(${CARD_BG},${CARD_BG}),
          linear-gradient(
            135deg,
            ${meta.accent}40,
            ${goldA(0.12)}
          )
        `,

        backgroundOrigin: "border-box",
        backgroundClip: "padding-box, border-box",

        boxShadow:
          "0 2px 14px rgba(201,168,76,.08)",

        position: "relative",
        overflow: "hidden",

        cursor: "pointer",

        animation:
          `fadeSlideUp .45s ${delay}s ease both`,

        transition:
          "transform .2s ease, box-shadow .2s ease",

        "&:hover": {
          transform: "translateY(-3px)",
          boxShadow:
            "0 8px 22px rgba(201,168,76,.15)",

          backgroundImage: `
            linear-gradient(${CARD_BG_HOVER},${CARD_BG_HOVER}),
            linear-gradient(
              135deg,
              ${meta.accent}60,
              ${goldA(0.22)}
            )
          `,
        },

        "&:hover .stat-icon": {
          animation:
            "iconGlow 1.2s ease infinite",
        },
      }}
    >
      <Box
        className="stat-icon"
        sx={{
          width: 30,
          height: 30,
          borderRadius: "9px",

          bgcolor: `${meta.accent}18`,
          color: meta.accent,

          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          mb: 1.6,
        }}
      >
        <Box
          sx={{
            fontSize: 14,
            display: "flex",
          }}
        >
          {meta.icon}
        </Box>
      </Box>

      <Typography
        sx={{
          fontSize: 10,
          fontWeight: 600,
          color: inkA(0.4),
          letterSpacing: ".7px",
          textTransform: "uppercase",
          mb: 0.6,
        }}
      >
        {title}
      </Typography>

      <Typography
        sx={{
          ...display,
          fontSize: 27,
          fontWeight: 600,
          letterSpacing: -0.5,
          color: INK,
          mb: 0.4,
        }}
      >
        {formattedValue}
      </Typography>

      <Typography
        sx={{
          fontSize: 10.5,
          color: meta.accent,

          display: "flex",
          alignItems: "center",
          gap: 0.4,

          fontWeight: 600,
        }}
      >
        <TrendingUpIcon sx={{ fontSize: 12 }} />

        {meta.trend}
      </Typography>

      <Box
        sx={{
          position: "absolute",
          bottom: 12,
          right: 14,
          opacity: 0.7,
        }}
      >
        <svg
          width="48"
          height="20"
          viewBox="0 0 48 20"
          fill="none"
          aria-hidden="true"
        >
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
});



const UserRow = memo(function UserRow({
  user,
  delay = 0,
}) {
  return (
    <Box
      sx={{
        display: "flex",
        alignItems: "center",
        gap: 1.2,

        py: 1,
        px: 0.5,

        borderRadius: "10px",

        animation:
          `slideInLeft .35s ${delay}s ease both`,

        transition: "background .15s",

        "&:hover": {
          bgcolor: goldA(0.07),
        },
      }}
    >
      <Box
        sx={{
          width: 30,
          height: 30,
          borderRadius: "9px",

          bgcolor: "rgba(127,119,221,.14)",
          color: "#6a61d1",

          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          fontSize: 12,
          fontWeight: 700,

          flexShrink: 0,

          ...display,
        }}
      >
        {user.name?.charAt(0) || "?"}
      </Box>

      <Box
        sx={{
          flex: 1,
          minWidth: 0,
        }}
      >
        <Typography
          sx={{
            fontSize: 12.5,
            fontWeight: 600,
            color: INK,

            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {user.name}
        </Typography>

        <Typography
          sx={{
            fontSize: 10.5,
            color: inkA(0.42),

            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {user.email}
        </Typography>
      </Box>

      <Typography
        sx={{
          ...mono,
          fontSize: 9.5,
          color: inkA(0.3),
          flexShrink: 0,
        }}
      >
        {user.joined_at || "—"}
      </Typography>
    </Box>
  );
});

const BookRow = memo(function BookRow({
  book,
  index,
  delay = 0,
}) {
  const spineColor =
    BOOK_SPINE_COLORS[
      index % BOOK_SPINE_COLORS.length
    ];

  return (
    <Box
      sx={{
        display: "flex",
        alignItems: "center",
        gap: 1.2,

        py: 1,
        px: 0.5,

        borderRadius: "10px",

        animation:
          `slideInRight .35s ${delay}s ease both`,

        transition: "background .15s",

        "&:hover": {
          bgcolor: goldA(0.07),
        },
      }}
    >
      <Box
        sx={{
          width: 5,
          alignSelf: "stretch",
          minHeight: 32,

          borderRadius: "2px 0 0 2px",

          bgcolor: `${spineColor}80`,

          flexShrink: 0,
        }}
      />

      <Box
        sx={{
          flex: 1,
          minWidth: 0,
        }}
      >
        <Typography
          sx={{
            ...display,
            fontSize: 13,
            fontWeight: 600,
            color: INK,

            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
          title={book.title}
        >
          {book.title}
        </Typography>

        <Typography
          sx={{
            fontSize: 10.5,
            color: inkA(0.42),

            overflow: "hidden",
            textOverflow: "ellipsis",
            whiteSpace: "nowrap",
          }}
        >
          {book.authors?.join(", ") ||
            "Unknown author"}
        </Typography>
      </Box>

      {book.average_rate > 0 && (
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            gap: 0.3,
            flexShrink: 0,
          }}
        >
          <StarRateRoundedIcon
            sx={{
              fontSize: 13,
              color: GOLD,
            }}
          />

          <Typography
            sx={{
              ...mono,
              fontSize: 11,
              color: inkA(0.5),
              fontWeight: 600,
            }}
          >
            {book.average_rate}
          </Typography>
        </Box>
      )}

      <Typography
        sx={{
          ...mono,
          fontSize: 11.5,
          color: GOLD_DARK,
          fontWeight: 700,

          flexShrink: 0,
          minWidth: 56,
          textAlign: "right",
        }}
      >
        {Number(
          book.sale_price ?? 0
        ).toLocaleString()}
      </Typography>
    </Box>
  );
});



const AdCard = memo(function AdCard({
  ad,
  adIndex,
}) {
  return (
    <Box
      sx={{
        bgcolor: CARD_BG,

        border: `1px solid ${goldA(0.16)}`,

        borderRadius: "22px",

        overflow: "hidden",

        display: "flex",
        flexDirection: "column",

        boxShadow:
          "0 2px 14px rgba(201,168,76,.08)",

        transition:
          "border-color .25s, box-shadow .25s",

        "&:hover": {
          borderColor: goldA(0.4),
          boxShadow:
            "0 8px 22px rgba(201,168,76,.14)",
        },
      }}
    >
      <Box
        sx={{
          height: 168,

          bgcolor: goldA(0.06),

          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          position: "relative",

          fontSize: 46,
        }}
      >
        {ad.emoji}
      </Box>

      <Box
        sx={{
          p: "14px 16px",
          flex: 1,
        }}
      >
        <Typography
          sx={{
            ...display,
            fontWeight: 600,
            fontSize: 14.5,
            color: INK,
            mb: 0.5,
          }}
        >
          {ad.title}
        </Typography>

        <Typography
          sx={{
            fontSize: 12,
            color: inkA(0.52),
            lineHeight: 1.5,
          }}
        >
          {ad.desc}
        </Typography>
      </Box>

      <Box
        sx={{
          display: "flex",
          justifyContent: "center",
          gap: "5px",
          pb: 1.5,
        }}
      >
        {ADS.map((_, i) => (
          <Box
            key={i}
            sx={{
              height: 4,
              borderRadius: "2px",

              width:
                i === adIndex
                  ? 20
                  : 8,

              bgcolor:
                i === adIndex
                  ? GOLD
                  : goldA(0.22),

              transition:
                "width .3s ease",
            }}
          />
        ))}
      </Box>
    </Box>
  );
});


export default function Dashboard() {
  const dispatch = useDispatch();

  const [adIndex, setAdIndex] = useState(0);

  const {
    dashboardStats,
    loading,
    loaded,
    lastFetched,
    error,
  } = useSelector(
    (state) => state.dashboard
  );

  

  useEffect(() => {
    injectFonts();
    injectKeyframes();
  }, []);

 

  useEffect(() => {
    const CACHE_TIME =
      5 * 60 * 1000;

    const isFresh =
      lastFetched &&
      Date.now() - lastFetched <
        CACHE_TIME;

    if (!loaded || !isFresh) {
      dispatch(getDashboardStats());
    }
  }, [
    dispatch,
    loaded,
    lastFetched,
  ]);

 

  useEffect(() => {
    if (!window.Echo) {
      return;
    }

    const userId = 1;

    const channel =
      window.Echo.private(
        `App.Models.User.${userId}`
      );

    channel.notification(
      (notification) => {
        console.log(
          "إشعار جديد وصل:",
          notification
        );
      }
    );

    return () => {
      try {
        window.Echo.leave(
          `private-App.Models.User.${userId}`
        );
      } catch (error) {
        console.warn(
          "Echo cleanup failed:",
          error
        );
      }
    };
  }, []);



  useEffect(() => {
    if (!ADS?.length) {
      return;
    }

    const timer = setInterval(() => {
      setAdIndex(
        (previous) =>
          (previous + 1) %
          ADS.length
      );
    }, 4500);

    return () => {
      clearInterval(timer);
    };
  }, []);


  const statsCards = useMemo(() => {
    if (!dashboardStats?.counts) {
      return [];
    }

    return [
      {
        title: "Users",
        value:
          dashboardStats.counts
            .total_customers,
      },

      {
        title: "Books",
        value:
          dashboardStats.counts
            .total_books,
      },

      {
        title: "Revenue",
        value:
          dashboardStats.counts
            .total_revenue,
      },

      {
        title: "Categories",
        value:
          dashboardStats.counts
            .total_categories,
      },

      {
        title: "Active Members",
        value:
          dashboardStats.counts
            .active_members,
      },

      {
        title: "Current Borrowed",
        value:
          dashboardStats.counts
            .current_borrowed,
      },
    ];
  }, [dashboardStats]);

  // eslint-disable-next-line react-hooks/exhaustive-deps
  const booksPerCategory =
    dashboardStats
      ?.books_per_category ?? [];

  const recentUsers =
    dashboardStats?.recent_users ?? [];

  const latestBooks =
    dashboardStats?.latest_books ?? [];

  const maxCategoryCount =
    useMemo(() => {
      return booksPerCategory.reduce(
        (max, category) =>
          Math.max(
            max,
            category.count || 0
          ),
        0
      );
    }, [booksPerCategory]);

  const currentAd =
    ADS?.[adIndex];

  

  if (
    loading &&
    !dashboardStats
  ) {
    return (
      <Box
        sx={{
          minHeight: "100vh",

          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          bgcolor: PAGE_BG,
        }}
      >
        <CircularProgress
          size={34}
          thickness={4}
          sx={{
            color: GOLD,
          }}
        />
      </Box>
    );
  }


  if (
    error &&
    !dashboardStats
  ) {
    return (
      <Box
        sx={{
          minHeight: "100vh",

          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          bgcolor: PAGE_BG,

          p: 3,
        }}
      >
        <Box
          sx={{
            textAlign: "center",
            maxWidth: 400,
          }}
        >
          <Typography
            sx={{
              ...display,
              fontSize: 24,
              fontWeight: 600,
              color: INK,
              mb: 1,
            }}
          >
            Unable to load dashboard
          </Typography>

          <Typography
            sx={{
              fontSize: 13,
              color: inkA(0.55),
              mb: 2,
            }}
          >
            Something went wrong while
            loading the dashboard data.
          </Typography>

          <Button
            onClick={() =>
              dispatch(
                getDashboardStats()
              )
            }
            sx={{
              color: "#fff",
              borderRadius: "12px",
              px: 3,

              background:
                `linear-gradient(135deg,${GOLD},${GOLD_DEEP})`,

              textTransform: "none",
              fontWeight: 700,
            }}
          >
            Try again
          </Button>
        </Box>
      </Box>
    );
  }

  return (
    <Box
      sx={{
        minHeight: "100vh",

        bgcolor: PAGE_BG,

        p: {
          xs: 2,
          md: "20px 24px",
        },

        fontFamily:
          "Inter, sans-serif",

        animation:
          "fadeSlideDown .35s ease both",

        position: "relative",

        overflow: "hidden",
      }}
    >
  

      <Box
        sx={{
          position: "fixed",

          top: -120,
          right: -100,

          width: 380,
          height: 380,

          borderRadius: "50%",

          background:
            "radial-gradient(circle, rgba(201,168,76,.15) 0%, transparent 70%)",

          animation:
            "floatBlobA 12s ease-in-out infinite",

          pointerEvents: "none",

          zIndex: 0,

          willChange: "transform",
        }}
      />

      <Box
        sx={{
          position: "fixed",

          bottom: -140,
          left: -100,

          width: 420,
          height: 420,

          borderRadius: "50%",

          background:
            "radial-gradient(circle, rgba(201,168,76,.11) 0%, transparent 70%)",

          animation:
            "floatBlobB 14s ease-in-out infinite",

          pointerEvents: "none",

          zIndex: 0,

          willChange: "transform",
        }}
      />

      

      <Box
        sx={{
          position: "relative",
          zIndex: 1,
        }}
      >
     

        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent:
              "space-between",

            mb: 2.5,

            px: "18px",
            height: 58,

            bgcolor:
              "rgba(255,255,255,.82)",

            border:
              `1px solid ${goldA(0.2)}`,

            borderRadius: "22px",

            position: "sticky",

            top: 0,

            zIndex: 10,

            backdropFilter:
              "blur(10px)",

            boxShadow:
              "0 2px 16px rgba(201,168,76,.08)",

            animation:
              "fadeSlideDown .35s ease both",
          }}
        >
          <Box
            sx={{
              display: "flex",
              alignItems: "center",
              gap: 1.4,
            }}
          >
            <Box
              sx={{
                width: 36,
                height: 36,

                position:
                  "relative",

                perspective: "120px",

                flexShrink: 0,
              }}
            >
              <Box
                sx={{
                  position:
                    "absolute",

                  inset: 0,

                  borderRadius: "8px",

                  background:
                    `linear-gradient(135deg,${GOLD},${GOLD_DEEP})`,

                  display: "flex",

                  alignItems:
                    "center",

                  justifyContent:
                    "center",
                }}
              >
                <Box
                  sx={{
                    width: 1,
                    height: 22,
                    bgcolor:
                      "rgba(255,255,255,.4)",
                  }}
                />
              </Box>

              <Box
                sx={{
                  position:
                    "absolute",

                  top: 0,
                  left: "50%",

                  width: "50%",
                  height: "100%",

                  borderRadius:
                    "0 8px 8px 0",

                  background:
                    "linear-gradient(135deg,#e3c876,#c9a84c)",

                  transformOrigin:
                    "0% 50%",

                  animation:
                    "pageTurn 6s ease-in-out infinite",
                }}
              />
            </Box>

            <Box>
              <Typography
                sx={{
                  ...display,

                  fontWeight: 600,
                  fontSize: 16,

                  color: INK,

                  letterSpacing: -.2,
                  lineHeight: 1.1,
                }}
              >
                Hiber &amp; Waraq
              </Typography>

              <Typography
                sx={{
                  fontSize: 9.5,

                  color:
                    inkA(0.4),

                  letterSpacing: ".6px",

                  textTransform:
                    "uppercase",

                  fontWeight: 600,
                }}
              >
                Library Dashboard
              </Typography>
            </Box>
          </Box>

          <Box
            sx={{
              display: "flex",
              alignItems: "center",
              gap: 1,
            }}
          >
            {[
              <NotificationsNoneIcon
                key="notifications"
                sx={{ fontSize: 17 }}
              />,

              <SettingsOutlinedIcon
                key="settings"
                sx={{ fontSize: 17 }}
              />,
            ].map(
              (icon, index) => (
                <IconButton
                  key={index}
                  sx={{
                    width: 32,
                    height: 32,

                    borderRadius:
                      "50%",

                    bgcolor:
                      goldA(0.08),

                    border:
                      `1px solid ${goldA(0.18)}`,

                    color:
                      inkA(0.55),

                    "&:hover": {
                      bgcolor:
                        goldA(0.16),

                      color: INK,
                    },

                    transition:
                      "background .15s",
                  }}
                >
                  {icon}
                </IconButton>
              )
            )}

            <Box
              sx={{
                width: 32,
                height: 32,

                borderRadius: "50%",

                background:
                  `linear-gradient(135deg,${GOLD},${GOLD_DEEP})`,

                display: "flex",

                alignItems:
                  "center",

                justifyContent:
                  "center",

                fontSize: 11,

                fontWeight: 700,

                color: "#fff",

                ...display,

                animation:
                  "ringPulse 3s ease infinite",

                ml: 0.5,

                cursor: "pointer",
              }}
            >
              AD
            </Box>
          </Box>
        </Box>

        

        <Box
          sx={{
            display: "grid",

            gridTemplateColumns: {
              xs: "1fr",
              md: "1fr 280px",
            },

            gap: 2,

            mb: 2.5,

            animation:
              "fadeSlideUp .4s .05s ease both",
          }}
        >
          <Box
            sx={{
              p: {
                xs: 3,
                md: "36px 40px",
              },

              borderRadius: "26px",

              background: CARD_BG,

              border:
                `1px solid ${goldA(0.22)}`,

              boxShadow:
                "0 4px 20px rgba(201,168,76,.1)",

              position:
                "relative",

              overflow:
                "hidden",
            }}
          >
            <Box
              sx={{
                position:
                  "absolute",

                top: -80,
                right: -60,

                width: 280,
                height: 280,

                background:
                  "radial-gradient(circle,rgba(201,168,76,.14) 0%,transparent 70%)",

                pointerEvents:
                  "none",
              }}
            />

            <Chip
              label="● Live System"
              size="small"
              sx={{
                mb: 2.5,

                bgcolor:
                  goldA(0.12),

                border:
                  `1px solid ${goldA(0.28)}`,

                color:
                  GOLD_DARK,

                fontWeight: 600,

                fontSize: 11,

                letterSpacing: .5,

                height: 24,

                borderRadius:
                  "20px",
              }}
            />

            <Typography
              sx={{
                ...display,

                fontSize: {
                  xs: 28,
                  md: 38,
                },

                fontWeight: 600,

                letterSpacing: -0.5,

                lineHeight: 1.08,

                mb: 1.5,

                color: INK,
              }}
            >
              Welcome back,
              <br />

              <Box
                component="span"
                sx={{
                  color:
                    GOLD_DARK,

                  fontStyle:
                    "italic",
                }}
              >
                Library Admin
              </Box>
            </Typography>

            <Typography
              sx={{
                fontSize: 13.5,

                color:
                  inkA(0.58),

                lineHeight: 1.7,

                maxWidth: 400,

                mb: 3.5,
              }}
            >
              Monitor performance,
              track engagement, and
              manage your entire library
              ecosystem from a unified
              intelligent dashboard.
            </Typography>

            <Button
              endIcon={
                <SpaceDashboardOutlinedIcon
                  sx={{
                    fontSize: 15,
                  }}
                />
              }
              sx={{
                px: 3,
                py: 1.2,

                borderRadius: "12px",

                fontWeight: 700,

                textTransform:
                  "none",

                fontSize: 13.5,

                color: "#fff",

                background:
                  `linear-gradient(135deg,${GOLD},${GOLD_DEEP})`,

                letterSpacing: .2,

                "&:hover": {
                  transform:
                    "translateY(-2px)",

                  boxShadow:
                    "0 10px 24px rgba(201,168,76,.25)",
                },

                transition:
                  "transform .2s, box-shadow .2s",
              }}
            >
              Enter Control Panel
            </Button>
          </Box>

          {currentAd && (
            <AdCard
              ad={currentAd}
              adIndex={adIndex}
            />
          )}
        </Box>

       

        <Box
          sx={{
            display: "grid",

            gridTemplateColumns: {
              xs: "1fr 1fr",
              sm: "repeat(3,1fr)",
              md: "repeat(6,1fr)",
            },

            gap: 2,

            mb: 2.5,
          }}
        >
          {statsCards.map(
            (stat, index) => {
              const meta =
                STAT_META[
                  stat.title
                ] ||
                EXTRA_STAT_META[
                  stat.title
                ] || {
                  icon: null,
                  accent:
                    GOLD_DARK,
                  trend: "",
                };

              return (
                <StatCard
                  key={stat.title}
                  title={stat.title}
                  value={stat.value}
                  meta={meta}
                  delay={
                    0.1 +
                    index * 0.04
                  }
                />
              );
            }
          )}
        </Box>

      

        <Box
          sx={{
            p: {
              xs: 2.5,
              md: "24px 26px",
            },

            borderRadius: "26px",

            bgcolor: CARD_BG,

            border:
              `1px solid ${goldA(0.15)}`,

            boxShadow:
              "0 4px 20px rgba(201,168,76,.08)",

            position:
              "relative",

            overflow:
              "hidden",

            animation:
              "fadeSlideUp .45s .3s ease both",
          }}
        >
          <Box
            sx={{
              position:
                "absolute",

              top: 0,
              left: 0,
              right: 0,

              height: 2,

              background:
                "linear-gradient(90deg,transparent,rgba(201,168,76,.15),rgba(201,168,76,.85),rgba(201,168,76,.15),transparent)",

              backgroundSize:
                "200% 100%",

              animation:
                "shimmerSweep 7s linear infinite",
            }}
          />

          <Box
            sx={{
              display: "flex",

              alignItems:
                "center",

              justifyContent:
                "space-between",

              mb: 3,
            }}
          >
            <Box>
              <Typography
                sx={{
                  ...display,

                  fontSize: 16.5,

                  fontWeight: 600,

                  color: INK,

                  letterSpacing: -.2,
                }}
              >
                Library Insights
              </Typography>

              <Typography
                sx={{
                  fontSize: 11.5,

                  color:
                    inkA(0.4),

                  mt: 0.3,
                }}
              >
                Categories, new members,
                and latest additions
              </Typography>
            </Box>

            <Chip
              label="● Live"
              size="small"
              sx={{
                bgcolor:
                  "rgba(63,184,115,.12)",

                color:
                  "#2f9b62",

                fontWeight: 700,

                fontSize: 10.5,

                letterSpacing: .5,

                height: 22,

                borderRadius:
                  "20px",
              }}
            />
          </Box>

          <Box
            sx={{
              display: "grid",

              gridTemplateColumns: {
                xs: "1fr",
                md: "1fr 1fr 1.2fr",
              },

              gap: 3,
            }}
          >
          

            <Box>
              <Box
                sx={{
                  display: "flex",
                  alignItems:
                    "center",
                  gap: 1,
                  mb: 2,
                }}
              >
                <Box
                  sx={{
                    width: 26,
                    height: 26,

                    borderRadius:
                      "8px",

                    bgcolor:
                      goldA(0.14),

                    color:
                      GOLD_DARK,

                    display:
                      "flex",

                    alignItems:
                      "center",

                    justifyContent:
                      "center",
                  }}
                >
                  <LocalLibraryOutlinedIcon
                    sx={{
                      fontSize: 14,
                    }}
                  />
                </Box>

                <Typography
                  sx={{
                    fontSize: 11.5,

                    fontWeight: 700,

                    color:
                      inkA(0.62),

                    letterSpacing: .3,
                  }}
                >
                  Books per Category
                </Typography>
              </Box>

              {booksPerCategory.length >
              0 ? (
                booksPerCategory.map(
                  (category, index) => (
                    <CategoryBar
                      key={
                        category.name
                      }
                      name={
                        category.name
                      }
                      count={
                        category.count
                      }
                      max={
                        maxCategoryCount
                      }
                      color={
                        CATEGORY_COLORS[
                          index %
                            CATEGORY_COLORS.length
                        ]
                      }
                      delay={
                        0.35 +
                        index * 0.04
                      }
                    />
                  )
                )
              ) : (
                <Typography
                  sx={{
                    color:
                      inkA(0.3),
                    fontSize: 12.5,
                  }}
                >
                  No categories yet
                </Typography>
              )}
            </Box>

           

            <Box>
              <Box
                sx={{
                  display: "flex",

                  alignItems:
                    "center",

                  gap: 1,

                  mb: 2,
                }}
              >
                <Box
                  sx={{
                    width: 26,
                    height: 26,

                    borderRadius:
                      "8px",

                    bgcolor:
                      "rgba(127,119,221,.13)",

                    color:
                      "#6a61d1",

                    display:
                      "flex",

                    alignItems:
                      "center",

                    justifyContent:
                      "center",
                  }}
                >
                  <PersonAddAltOutlinedIcon
                    sx={{
                      fontSize: 14,
                    }}
                  />
                </Box>

                <Typography
                  sx={{
                    fontSize: 11.5,

                    fontWeight: 700,

                    color:
                      inkA(0.62),

                    letterSpacing: .3,
                  }}
                >
                  Recent Members
                </Typography>
              </Box>

              {recentUsers.length >
              0 ? (
                recentUsers.map(
                  (user, index) => (
                    <UserRow
                      key={user.id}
                      user={user}
                      delay={
                        0.4 +
                        index * 0.04
                      }
                    />
                  )
                )
              ) : (
                <Typography
                  sx={{
                    color:
                      inkA(0.3),
                    fontSize: 12.5,
                  }}
                >
                  No recent members
                </Typography>
              )}
            </Box>

        

            <Box>
              <Box
                sx={{
                  display: "flex",

                  alignItems:
                    "center",

                  justifyContent:
                    "space-between",

                  mb: 2,
                }}
              >
                <Box
                  sx={{
                    display: "flex",

                    alignItems:
                      "center",

                    gap: 1,
                  }}
                >
                  <Box
                    sx={{
                      width: 26,
                      height: 26,

                      borderRadius:
                        "8px",

                      bgcolor:
                        "rgba(63,184,115,.13)",

                      color:
                        "#2f9b62",

                      display:
                        "flex",

                      alignItems:
                        "center",

                      justifyContent:
                        "center",
                    }}
                  >
                    <AutoStoriesOutlinedIcon
                      sx={{
                        fontSize: 14,
                      }}
                    />
                  </Box>

                  <Typography
                    sx={{
                      fontSize: 11.5,

                      fontWeight: 700,

                      color:
                        inkA(0.62),

                      letterSpacing: .3,
                    }}
                  >
                    Latest Books
                  </Typography>
                </Box>

                <Typography
                  sx={{
                    fontSize: 11,

                    color:
                      GOLD_DARK,

                    fontWeight: 700,

                    cursor: "pointer",
                  }}
                >
                  View all →
                </Typography>
              </Box>

              {latestBooks.length >
              0 ? (
                latestBooks.map(
                  (book, index) => (
                    <BookRow
                      key={book.id}
                      book={book}
                      index={index}
                      delay={
                        0.45 +
                        index * 0.04
                      }
                    />
                  )
                )
              ) : (
                <Typography
                  sx={{
                    color:
                      inkA(0.3),
                    fontSize: 12.5,
                  }}
                >
                  No books yet
                </Typography>
              )}
            </Box>
          </Box>
        </Box>

    

        {loading &&
          dashboardStats && (
            <Box
              sx={{
                position: "fixed",

                bottom: 20,
                right: 20,

                display: "flex",
                alignItems:
                  "center",

                gap: 1,

                px: 1.5,
                py: 0.8,

                bgcolor:
                  "rgba(255,255,255,.9)",

                border:
                  `1px solid ${goldA(0.18)}`,

                borderRadius:
                  "12px",

                boxShadow:
                  "0 4px 16px rgba(0,0,0,.08)",

                zIndex: 100,
              }}
            >
              <CircularProgress
                size={14}
                thickness={4}
                sx={{
                  color: GOLD,
                }}
              />

              <Typography
                sx={{
                  fontSize: 10.5,
                  color:
                    inkA(0.5),
                  fontWeight: 600,
                }}
              >
                Updating...
              </Typography>
            </Box>
          )}
      </Box>
    </Box>
  );
}