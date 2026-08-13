import { useEffect, useState } from "react";

import {
  useDispatch,
  useSelector,
} from "react-redux";

import {
  Box,
  Typography,
  Chip,
  CircularProgress,
  Pagination,
} from "@mui/material";

import {
  motion,
} from "framer-motion";

import {
  Users,
  Award,
  Phone,
  UserCircle,
} from "lucide-react";

import {
  fetchUsers,
  getAllOperationForUser,
} from "../../Core/Redux/Thunks/UserThunk";


const BG = "#FBF7ED";
const SURFACE = "#FFFFFF";
const SURFACE_HOV = "#FFFCF3";

const GOLD = "#c9a84c";
const GOLD2 = "#8b5e1a";
const GOLD_DARK = "#a8822f";

const TEXT = "#2b2416";

const inkA = (a) =>
  `rgba(43,36,22,${a})`;

const goldA = (a) =>
  `rgba(201,168,76,${a})`;

const BORDER = goldA(0.18);

const MUTED = inkA(0.5);

const display = {
  fontFamily: "'Fraunces', serif",
};

const mono = {
  fontFamily: "'IBM Plex Mono', monospace",
};


const FONT_IMPORT_ID = "lib-fonts";

const FONT_HREF =
  "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght,SOFT,WONK@9..144,300..700,0..100,0..1&family=Inter:wght@400;500;600;700;800&family=IBM+Plex+Mono:wght@500;600&display=swap";

function injectFonts() {
  if (
    document.getElementById(FONT_IMPORT_ID)
  ) {
    return;
  }

  const link =
    document.createElement("link");

  link.id = FONT_IMPORT_ID;
  link.rel = "stylesheet";
  link.href = FONT_HREF;

  document.head.appendChild(link);
}


function ProfileCard({
  profile,
  loading,
}) {
  if (loading) {
    return (
      <Box
        sx={{
          minHeight: 170,

          display: "flex",
          alignItems: "center",
          justifyContent: "center",

          borderRadius: "18px",

          bgcolor: SURFACE,

          border:
            `1px solid ${BORDER}`,

          boxShadow:
            "0 2px 14px rgba(201,168,76,.08)",
        }}
      >
        <CircularProgress
          size={24}
          sx={{
            color: GOLD,
          }}
        />
      </Box>
    );
  }

  return (
    <Box
      component={motion.div}
      initial={{
        opacity: 0,
        y: 10,
      }}
      animate={{
        opacity: 1,
        y: 0,
      }}
      transition={{
        duration: 0.2,
      }}
      sx={{
        p: "20px",

        borderRadius: "18px",

        bgcolor: SURFACE,

        border:
          `1px solid ${BORDER}`,

        boxShadow:
          "0 2px 14px rgba(201,168,76,.08)",

        transition:
          "all 0.2s",

        "&:hover": {
          borderColor:
            `${GOLD}40`,

          transform:
            "translateY(-2px)",

          bgcolor:
            SURFACE_HOV,

          boxShadow:
            "0 10px 26px rgba(201,168,76,.16)",
        },
      }}
    >

      <Box
        sx={{
          display: "flex",
          alignItems: "center",

          gap: 1.5,

          mb: 2,
        }}
      >
        <Box
          sx={{
            width: 40,
            height: 40,

            borderRadius: "12px",

            background:
              `linear-gradient(
                135deg,
                ${GOLD},
                ${GOLD2}
              )`,

            display: "flex",

            alignItems: "center",

            justifyContent:
              "center",

            flexShrink: 0,

            boxShadow:
              "0 4px 12px rgba(201,168,76,.18)",
          }}
        >
          <UserCircle
            size={20}
            color="#fff"
          />
        </Box>

        <Box
          sx={{
            minWidth: 0,
          }}
        >
          <Typography
            sx={{
              ...display,

              fontSize: 14,

              fontWeight: 600,

              color: TEXT,

              whiteSpace:
                "nowrap",

              overflow:
                "hidden",

              textOverflow:
                "ellipsis",
            }}
          >
            {profile?.profile?.name ||
              profile?.name ||
              "—"}
          </Typography>

          {(profile?.profile?.phone ||
            profile?.phone) && (
            <Typography
              sx={{
                ...mono,

                fontSize: 11,

                color: MUTED,

                display: "flex",

                alignItems:
                  "center",

                gap: 0.5,

                mt: 0.2,
              }}
            >
              <Phone size={11} />

              {profile?.profile?.phone ||
                profile?.phone}
            </Typography>
          )}
        </Box>
      </Box>


      <Box
        sx={{
          display: "flex",

          alignItems:
            "center",

          justifyContent:
            "space-between",

          pt: 1.5,

          borderTop:
            `1px solid ${BORDER}`,
        }}
      >
        {(profile?.profile?.member_type ||
          profile?.member_type) && (
          <Chip
            label={
              profile?.profile
                ?.member_type ||
              profile?.member_type
            }
            size="small"
            sx={{
              bgcolor:
                "rgba(201,168,76,0.1)",

              border:
                "1px solid rgba(201,168,76,0.2)",

              color: GOLD_DARK,

              fontWeight: 700,

              fontSize: 11,

              height: 24,

              borderRadius: "8px",

              fontFamily:
                "'IBM Plex Mono', monospace",
            }}
          />
        )}

        {(profile?.profile?.points !==
          undefined ||
          profile?.points !==
            undefined) && (
          <Box
            sx={{
              display: "flex",

              alignItems:
                "center",

              gap: 0.5,
            }}
          >
            <Award
              size={14}
              color="#5f8e20"
            />

            <Typography
              sx={{
                ...mono,

                fontSize: 13,

                fontWeight: 600,

                color: "#5f8e20",
              }}
            >
              {profile?.profile?.points ??
                profile?.points}{" "}
              pts
            </Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
}


export default function UserProfilePage() {
  const dispatch =
    useDispatch();

  const {
    users = [],
    pagination,
    profiles = {},
    profilesLoading = {},
    loading,
  } = useSelector(
    (state) => state.user
  );

  const [
    currentPage,
    setCurrentPage,
  ] = useState(1);

 
  useEffect(() => {
    injectFonts();
  }, []);

 
  useEffect(() => {
    dispatch(
      fetchUsers(currentPage)
    );
  }, [
    dispatch,
    currentPage,
  ]);

  
  useEffect(() => {
    if (!users.length) {
      return;
    }

    const usersWithoutCache =
      users.filter(
        (user) =>
          !profiles[user.id]
      );

    if (
      usersWithoutCache.length ===
      0
    ) {
      return;
    }


    Promise.all(
      usersWithoutCache.map(
        (user) =>
          dispatch(
            getAllOperationForUser(
              user.id
            )
          )
      )
    );
  }, [
    users,
    profiles,
    dispatch,
  ]);

  
  const totalPages =
    pagination?.last_page || 1;

  const handlePageChange = (
    event,
    page
  ) => {
    setCurrentPage(page);

    
    window.scrollTo({
      top: 0,
      behavior: "smooth",
    });
  };

  
  const firstLoading =
    loading &&
    users.length === 0;

  
  return (
    <Box
      sx={{
        minHeight: "100vh",

        bgcolor: BG,

        p: {
          xs: 2,
          md: "20px 24px",
        },

        fontFamily:
          "Inter, sans-serif",
      }}
    >
    

      <Box
        sx={{
          display: "flex",

          alignItems:
            "center",

          justifyContent:
            "space-between",

          mb: 3,

          px: "20px",

          height: 60,

          bgcolor:
            "rgba(255,255,255,0.75)",

          border:
            `1px solid ${BORDER}`,

          borderRadius: "16px",

          position: "sticky",

          top: 0,

          zIndex: 10,

          backdropFilter:
            "blur(16px)",

          boxShadow:
            "0 2px 16px rgba(201,168,76,.08)",
        }}
      >
        <Box
          sx={{
            display: "flex",

            alignItems:
              "center",

            gap: 1.5,
          }}
        >
          <Box
            sx={{
              width: 32,
              height: 32,

              borderRadius:
                "10px",

              background:
                `linear-gradient(
                  135deg,
                  ${GOLD},
                  ${GOLD2}
                )`,

              display: "flex",

              alignItems:
                "center",

              justifyContent:
                "center",
            }}
          >
            <Users
              size={17}
              color="#fff"
            />
          </Box>

          <Typography
            sx={{
              ...display,

              fontWeight: 600,

              fontSize: 16,

              color: TEXT,

              letterSpacing:
                -0.2,
            }}
          >
            User Profiles
          </Typography>
        </Box>

        <Box
          sx={{
            ...mono,

            px: "12px",

            py: "5px",

            borderRadius:
              "8px",

            bgcolor:
              "rgba(201,168,76,0.1)",

            border:
              "1px solid rgba(201,168,76,0.2)",

            fontSize: 11.5,

            fontWeight: 600,

            color: GOLD_DARK,
          }}
        >
          {pagination?.total ||
            0}{" "}
          users
        </Box>
      </Box>

    

      <Box
        sx={{
          p: {
            xs: 3,
            md: "36px 40px",
          },

          borderRadius:
            "20px",

          background:
            SURFACE,

          border:
            `1px solid ${goldA(
              0.22
            )}`,

          boxShadow:
            "0 4px 20px rgba(201,168,76,.1)",

          position:
            "relative",

          overflow:
            "hidden",

          mb: 2.5,
        }}
      >
        <Box
          sx={{
            position:
              "absolute",

            top: -100,

            right: -80,

            width: 300,

            height: 300,

            background:
              "radial-gradient(circle,rgba(201,168,76,0.16) 0%,transparent 70%)",

            pointerEvents:
              "none",
          }}
        />

        <Box
          sx={{
            display:
              "inline-flex",

            alignItems:
              "center",

            gap: "6px",

            mb: 2.2,

            px: "12px",

            py: "4px",

            borderRadius:
              "20px",

            bgcolor:
              "rgba(201,168,76,0.1)",

            border:
              "1px solid rgba(201,168,76,0.2)",

            fontSize: 11,

            fontWeight: 600,

            letterSpacing:
              0.5,

            color:
              GOLD_DARK,
          }}
        >
          ● Community
        </Box>

        <Typography
          sx={{
            ...display,

            fontSize: {
              xs: 24,
              md: 32,
            },

            fontWeight: 600,

            letterSpacing:
              -0.5,

            lineHeight:
              1.15,

            mb: 1.5,

            color: TEXT,
          }}
        >
          All member{" "}
          <Box
            component="span"
            sx={{
              color:
                GOLD_DARK,

              fontStyle:
                "italic",
            }}
          >
            profiles
          </Box>
        </Typography>

        <Typography
          sx={{
            fontSize: 13.5,

            color:
              inkA(0.58),

            lineHeight: 1.7,

            maxWidth: 440,
          }}
        >
          Browse profile details,
          membership type, and
          loyalty points for every
          registered member.
        </Typography>
      </Box>

    

      {firstLoading && (
        <Box
          sx={{
            display: "flex",

            justifyContent:
              "center",

            alignItems:
              "center",

            py: 8,
          }}
        >
          <CircularProgress
            size={32}
            sx={{
              color: GOLD,
            }}
          />
        </Box>
      )}

   

      {!loading &&
        users.length === 0 && (
          <Box
            sx={{
              textAlign:
                "center",

              py: 6,
            }}
          >
            <Typography
              sx={{
                ...display,

                fontSize: 15,

                fontWeight: 600,

                color: MUTED,
              }}
            >
              No users found
            </Typography>
          </Box>
        )}

      

      {users.length > 0 && (
        <>
          <Box
            sx={{
              display: "grid",

              gridTemplateColumns: {
                xs: "1fr",

                sm: "1fr 1fr",

                md:
                  "repeat(3, 1fr)",
              },

              gap: 2,

              opacity:
                loading
                  ? 0.65
                  : 1,

              transition:
                "opacity .2s",
            }}
          >
            {users.map(
              (user) => {
                const cached =
                  profiles[
                    user.id
                  ];

                const isProfileLoading =
                  profilesLoading[
                    user.id
                  ];

                return (
                  <ProfileCard
                    key={user.id}
                    profile={
                      cached
                    }
                    loading={
                      !cached &&
                      isProfileLoading
                    }
                  />
                );
              }
            )}
          </Box>

        

          {totalPages > 1 && (
            <Box
              sx={{
                display: "flex",

                justifyContent:
                  "center",

                alignItems:
                  "center",

                mt: 4,

                mb: 2,
              }}
            >
              <Pagination
                count={
                  totalPages
                }

                page={
                  currentPage
                }

                onChange={
                  handlePageChange
                }

                size="medium"

                sx={{
                  "& .MuiPaginationItem-root":
                    {
                      fontFamily:
                        "Inter, sans-serif",

                      fontWeight:
                        600,

                      color:
                        GOLD_DARK,

                      borderRadius:
                        "9px",
                    },

                  "& .Mui-selected":
                    {
                      bgcolor:
                        `${GOLD} !important`,

                      color:
                        "#fff",

                      boxShadow:
                        "0 4px 12px rgba(201,168,76,.25)",
                    },

                  "& .MuiPaginationItem-root:hover":
                    {
                      bgcolor:
                        goldA(
                          0.12
                        ),
                    },
                }}
              />
            </Box>
          )}
        </>
      )}
    </Box>
  );
}