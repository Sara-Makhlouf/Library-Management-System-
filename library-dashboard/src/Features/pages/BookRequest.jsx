import { useEffect, useState } from "react";

import { useDispatch, useSelector } from "react-redux";

import {
  Box,
  Typography,
  Chip,
  CircularProgress,
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Avatar,
  Divider,
} from "@mui/material";

import { motion } from "framer-motion";

import {
  BookOpen,
  Phone,
  CheckCircle2,
  Clock,
  XCircle,
  CalendarDays,
  Hash,
  RefreshCw,
} from "lucide-react";

import {
  fetchBookRequests,
  updateBookRequestStatus,
} from "../../Core/Redux/Thunks/BookRequestThunk";

import { clearBookRequestState } from "../../Core/Redux/Slice/BookRequestSlice";

import {
  GOLD,
  GOLD_DEEP as GOLD2,
  INK as TEXT,
  PAGE_BG as BG,
  CARD_BG as SURFACE,
  inkA,
  goldA,
} from "../../Core/Constants/ColorsUse";

const BORDER = goldA(0.15);
const MUTED = inkA(0.5);

const STATUS_META = {
  approved: {
    label: "Approved",
    color: "#3fb873",
    bg: "rgba(63,184,115,.10)",
    border: "rgba(63,184,115,.25)",
    icon: <CheckCircle2 size={14} />,
  },

  pending: {
    label: "Pending",
    color: GOLD2,
    bg: "rgba(201,168,76,.10)",
    border: "rgba(201,168,76,.25)",
    icon: <Clock size={14} />,
  },

  rejected: {
    label: "Rejected",
    color: "#e0655f",
    bg: "rgba(224,101,95,.10)",
    border: "rgba(224,101,95,.25)",
    icon: <XCircle size={14} />,
  },
};

function StatusChip({ status }) {
  const meta = STATUS_META[status] || STATUS_META.pending;

  return (
    <Chip
      icon={meta.icon}
      label={meta.label}
      size="small"
      sx={{
        color: meta.color,
        bgcolor: meta.bg,
        border: `1px solid ${meta.border}`,
        fontWeight: 700,
        borderRadius: "10px",

        "& .MuiChip-icon": {
          color: meta.color,
        },
      }}
    />
  );
}

// eslint-disable-next-line no-unused-vars
function InfoCard({
  icon,
  title,
  children,
  iconColor = GOLD2,
  iconBg = goldA(0.1),
}) {
  return (
    <Box
      component={motion.div}
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      sx={{
        p: {
          xs: 2,
          md: 2.5,
        },

        borderRadius: "18px",
        bgcolor: SURFACE,
        border: `1px solid ${BORDER}`,
        boxShadow: "0 4px 20px rgba(201,168,76,.06)",
        transition: "all .25s",

        "&:hover": {
          transform: "translateY(-2px)",
          borderColor: `${iconColor}45`,
          boxShadow: "0 8px 28px rgba(201,168,76,.10)",
        },
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          gap: 1.2,
          mb: 2.2,
        }}
      >
        <Box
          sx={{
            width: 34,
            height: 34,
            borderRadius: "10px",
            bgcolor: iconBg,
            color: iconColor,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {icon}
        </Box>

        <Typography
          sx={{
            fontSize: 13,
            fontWeight: 800,
            color: TEXT,
          }}
        >
          {title}
        </Typography>
      </Box>

      {children}
    </Box>
  );
}

// eslint-disable-next-line no-unused-vars
function Row({ label, value, icon }) {
  return (
    <Box
      sx={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        gap: 2,
        py: 1.15,
        borderBottom: `1px solid ${BORDER}`,

        "&:last-child": {
          borderBottom: "none",
        },
      }}
    >
      <Typography
        sx={{
          fontSize: 12,
          color: MUTED,
          fontWeight: 600,
          display: "flex",
          alignItems: "center",
          gap: 0.7,
          whiteSpace: "nowrap",
        }}
      >
        {icon}
        {label}
      </Typography>

      <Typography
        sx={{
          fontSize: 12.5,
          color: TEXT,
          fontWeight: 700,
          textAlign: "right",
          overflow: "hidden",
          textOverflow: "ellipsis",
        }}
      >
        {value ?? "—"}
      </Typography>
    </Box>
  );
}

const formatDate = (date) => {
  if (!date) return "—";

  const parsed = new Date(date);

  if (Number.isNaN(parsed.getTime())) {
    return "—";
  }

  return parsed.toLocaleDateString("en-GB", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
};

export default function BookRequestDetailsPage() {
  const dispatch = useDispatch();

  const {
    requests = [],
    loading,
    fetchLoading,
    error,
    fetchError,
    successMessage,
  } = useSelector((state) => state.BookRequest || {});

  const [selectedRequest, setSelectedRequest] = useState(null);
  const [adminNote, setAdminNote] = useState("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [selectedStatus, setSelectedStatus] = useState(null);

  useEffect(() => {
    dispatch(fetchBookRequests());
  }, [dispatch]);

  useEffect(() => {
    return () => {
      dispatch(clearBookRequestState());
    };
  }, [dispatch]);

  const handleRefresh = () => {
    if (!fetchLoading) {
      dispatch(fetchBookRequests());
    }
  };

  const openStatusDialog = (request, status) => {
    setSelectedRequest(request);
    setSelectedStatus(status);
    setAdminNote(request?.admin_note || "");
    setDialogOpen(true);
  };

  const handleUpdateStatus = async () => {
    if (!selectedRequest?.id || !selectedStatus) {
      return;
    }

    try {
      await dispatch(
        updateBookRequestStatus({
          requestId: selectedRequest.id,
          status: selectedStatus,
          admin_note: adminNote,
        })
      ).unwrap();

      setDialogOpen(false);

      dispatch(fetchBookRequests());
    } catch (err) {
    }
  };

  if (fetchLoading) {
    return (
      <Box
        sx={{
          minHeight: "100vh",
          bgcolor: BG,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
          gap: 2,
        }}
      >
        <CircularProgress sx={{ color: GOLD }} />

        <Typography
          sx={{
            color: MUTED,
            fontSize: 13,
          }}
        >
          Loading book requests...
        </Typography>
      </Box>
    );
  }

  if (fetchError) {
    return (
      <Box
        sx={{
          minHeight: "100vh",
          bgcolor: BG,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Box sx={{ textAlign: "center" }}>
          <XCircle size={40} color="#e0655f" />

          <Typography
            sx={{
              mt: 1.5,
              color: "#e0655f",
            }}
          >
            {fetchError?.message || "Failed to load requests."}
          </Typography>

          <Button
            onClick={handleRefresh}
            startIcon={<RefreshCw size={16} />}
            sx={{
              mt: 2,
              color: GOLD2,
              borderRadius: "10px",
              textTransform: "none",
              border: `1px solid ${goldA(0.25)}`,
            }}
          >
            Try Again
          </Button>
        </Box>
      </Box>
    );
  }

  return (
    <Box
      sx={{
        minHeight: "100vh",
        bgcolor: BG,
        p: {
          xs: 2,
          md: 3,
        },
        fontFamily: "Inter, sans-serif",
      }}
    >
      {/* HEADER */}

      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          gap: 2,
          mb: 3,
          p: 2,
          borderRadius: "18px",
          bgcolor: SURFACE,
          border: `1px solid ${BORDER}`,
          boxShadow: "0 4px 20px rgba(201,168,76,.06)",
        }}
      >
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            gap: 1.5,
            minWidth: 0,
          }}
        >
          <Box
            sx={{
              width: 42,
              height: 42,
              minWidth: 42,
              borderRadius: "12px",
              background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#fff",
            }}
          >
            <BookOpen size={20} />
          </Box>

          <Box sx={{ minWidth: 0 }}>
            <Typography
              sx={{
                fontSize: 17,
                fontWeight: 800,
                color: TEXT,
              }}
            >
              Book Requests
            </Typography>

            <Typography
              sx={{
                fontSize: 11.5,
                color: MUTED,
                mt: 0.2,
              }}
            >
              Manage customer book requests
            </Typography>
          </Box>
        </Box>


        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            gap: 1,
            flexShrink: 0,
          }}
        >
          <Chip
            label={`${requests.length} Requests`}
            sx={{
              bgcolor: goldA(0.1),
              color: GOLD2,
              border: `1px solid ${goldA(0.2)}`,
              fontWeight: 700,
            }}
          />

          <Button
            onClick={handleRefresh}
            disabled={fetchLoading}
            aria-label="Refresh book requests"
            sx={{
              minWidth: 40,
              width: 40,
              height: 40,
              p: 0,
              borderRadius: "12px",
              color: GOLD2,
              bgcolor: goldA(0.08),
              border: `1px solid ${goldA(0.2)}`,

              "&:hover": {
                bgcolor: goldA(0.15),
              },

              "&.Mui-disabled": {
                color: GOLD2,
                opacity: 0.7,
              },
            }}
          >
            <motion.div
              animate={
                fetchLoading
                  ? {
                      rotate: 360,
                    }
                  : {
                      rotate: 0,
                    }
              }
              transition={
                fetchLoading
                  ? {
                      duration: 0.8,
                      repeat: Infinity,
                      ease: "linear",
                    }
                  : {}
              }
            >
              <RefreshCw size={18} />
            </motion.div>
          </Button>
        </Box>
      </Box>


      {successMessage && (
        <Box
          sx={{
            mb: 2,
            p: 1.5,
            borderRadius: "12px",
            bgcolor: "rgba(63,184,115,.08)",
            border: "1px solid rgba(63,184,115,.2)",
            color: "#3fb873",
            display: "flex",
            alignItems: "center",
            gap: 1,
            fontSize: 13,
          }}
        >
          <CheckCircle2 size={16} />

          {successMessage}
        </Box>
      )}


      {error && (
        <Box
          sx={{
            mb: 2,
            p: 1.5,
            borderRadius: "12px",
            bgcolor: "rgba(224,101,95,.08)",
            border: "1px solid rgba(224,101,95,.2)",
            color: "#e0655f",
            display: "flex",
            alignItems: "center",
            gap: 1,
            fontSize: 13,
          }}
        >
          <XCircle size={16} />

          {error?.message || "Something went wrong."}
        </Box>
      )}


      {!requests.length ? (
        <Box
          sx={{
            py: 10,
            textAlign: "center",
            bgcolor: SURFACE,
            borderRadius: "18px",
            border: `1px solid ${BORDER}`,
          }}
        >
          <BookOpen size={42} color={GOLD2} />

          <Typography
            sx={{
              mt: 2,
              color: MUTED,
              fontSize: 14,
            }}
          >
            No book requests found.
          </Typography>

          <Button
            onClick={handleRefresh}
            startIcon={<RefreshCw size={15} />}
            sx={{
              mt: 2,
              color: GOLD2,
              borderRadius: "10px",
              textTransform: "none",
              fontWeight: 700,
              border: `1px solid ${goldA(0.25)}`,
            }}
          >
            Refresh
          </Button>
        </Box>
      ) : (

        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: 2,
          }}
        >
          {requests.map((request, index) => {
            const customer = request.customer;

            const initials =
              customer?.name
                ?.split(" ")
                .slice(0, 2)
                .map((word) => word[0]?.toUpperCase())
                .join("") || "?";

            return (
              <Box
                key={request.id ?? index}
                component={motion.div}
                initial={{
                  opacity: 0,
                  y: 15,
                }}
                animate={{
                  opacity: 1,
                  y: 0,
                }}
                transition={{
                  delay: index * 0.05,
                }}
                sx={{
                  p: {
                    xs: 2,
                    md: 2.5,
                  },

                  borderRadius: "20px",
                  bgcolor: SURFACE,
                  border: `1px solid ${BORDER}`,
                  boxShadow: "0 4px 18px rgba(201,168,76,.05)",
                  transition: "all .25s",

                  "&:hover": {
                    transform: "translateY(-2px)",
                    borderColor: goldA(0.3),
                    boxShadow: "0 10px 30px rgba(201,168,76,.09)",
                  },
                }}
              >

                <Box
                  sx={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "flex-start",
                    gap: 2,
                    mb: 2,
                  }}
                >
                  <Box
                    sx={{
                      display: "flex",
                      gap: 1.5,
                      minWidth: 0,
                    }}
                  >
                    <Box
                      sx={{
                        width: 46,
                        height: 46,
                        minWidth: 46,
                        borderRadius: "13px",
                        background: `linear-gradient(135deg,${GOLD},${GOLD2})`,
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        color: "#fff",
                      }}
                    >
                      <BookOpen size={21} />
                    </Box>

                    <Box sx={{ minWidth: 0 }}>
                      <Typography
                        sx={{
                          fontSize: 16,
                          fontWeight: 800,
                          color: TEXT,
                          overflow: "hidden",
                          textOverflow: "ellipsis",
                          whiteSpace: "nowrap",
                        }}
                      >
                        {request.book_title || "Untitled Book"}
                      </Typography>

                      <Typography
                        sx={{
                          mt: 0.3,
                          fontSize: 12,
                          color: MUTED,
                        }}
                      >
                        by {request.author_name || "Unknown Author"}
                      </Typography>
                    </Box>
                  </Box>

                  <StatusChip status={request.status} />
                </Box>

                <Divider
                  sx={{
                    borderColor: BORDER,
                    mb: 2,
                  }}
                />


                <Box
                  sx={{
                    display: "grid",
                    gridTemplateColumns: {
                      xs: "1fr",
                      sm: "1fr 1fr",
                      lg: "1fr 1fr 1fr",
                    },
                    gap: 1.5,
                  }}
                >

                  <Box
                    sx={{
                      p: 1.5,
                      borderRadius: "13px",
                      bgcolor: goldA(0.035),
                      border: `1px solid ${BORDER}`,
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: 10.5,
                        color: MUTED,
                        mb: 1,
                        fontWeight: 700,
                      }}
                    >
                      CUSTOMER
                    </Typography>

                    <Box
                      sx={{
                        display: "flex",
                        alignItems: "center",
                        gap: 1,
                      }}
                    >
                      <Avatar
                        sx={{
                          width: 34,
                          height: 34,
                          fontSize: 12,
                          fontWeight: 700,
                          bgcolor: "#6a61d1",
                        }}
                      >
                        {initials}
                      </Avatar>

                      <Box sx={{ minWidth: 0 }}>
                        <Typography
                          sx={{
                            fontSize: 12.5,
                            fontWeight: 700,
                            color: TEXT,
                          }}
                        >
                          {customer?.name || "—"}
                        </Typography>

                        <Typography
                          sx={{
                            fontSize: 11,
                            color: MUTED,
                            display: "flex",
                            alignItems: "center",
                            gap: 0.4,
                          }}
                        >
                          <Phone size={10} />

                          {customer?.phone || "—"}
                        </Typography>
                      </Box>
                    </Box>
                  </Box>


                  <Box
                    sx={{
                      p: 1.5,
                      borderRadius: "13px",
                      bgcolor: goldA(0.035),
                      border: `1px solid ${BORDER}`,
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: 10.5,
                        color: MUTED,
                        mb: 1,
                        fontWeight: 700,
                      }}
                    >
                      REQUEST
                    </Typography>

                    <Typography
                      sx={{
                        fontSize: 12,
                        color: TEXT,
                        fontWeight: 600,
                        display: "flex",
                        alignItems: "center",
                        gap: 0.7,
                      }}
                    >
                      <Hash size={12} color={GOLD2} />

                      Request #{request.id}
                    </Typography>

                    <Typography
                      sx={{
                        mt: 0.7,
                        fontSize: 11,
                        color: MUTED,
                        display: "flex",
                        alignItems: "center",
                        gap: 0.7,
                      }}
                    >
                      <CalendarDays size={12} />

                      {formatDate(request.created_at)}
                    </Typography>
                  </Box>


                  <Box
                    sx={{
                      p: 1.5,
                      borderRadius: "13px",
                      bgcolor: goldA(0.035),
                      border: `1px solid ${BORDER}`,
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: 10.5,
                        color: MUTED,
                        mb: 1,
                        fontWeight: 700,
                      }}
                    >
                      CUSTOMER NOTE
                    </Typography>

                    <Typography
                      sx={{
                        fontSize: 12,
                        color: TEXT,
                        lineHeight: 1.6,
                      }}
                    >
                      {request.notes || "No notes provided."}
                    </Typography>
                  </Box>
                </Box>


                {request.admin_note && (
                  <Box
                    sx={{
                      mt: 1.5,
                      p: 1.5,
                      borderRadius: "13px",
                      bgcolor: "rgba(151,196,89,.06)",
                      border: "1px solid rgba(151,196,89,.18)",
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: 10.5,
                        color: "#5f8e20",
                        fontWeight: 800,
                        mb: 0.5,
                      }}
                    >
                      ADMIN NOTE
                    </Typography>

                    <Typography
                      sx={{
                        fontSize: 12,
                        color: TEXT,
                      }}
                    >
                      {request.admin_note}
                    </Typography>
                  </Box>
                )}


                <Box
                  sx={{
                    mt: 2,
                    display: "flex",
                    justifyContent: "flex-end",
                    gap: 1,
                    flexWrap: "wrap",
                  }}
                >
                  <Button
                    onClick={() =>
                      openStatusDialog(request, "approved")
                    }
                    disabled={loading}
                    startIcon={<CheckCircle2 size={15} />}
                    sx={{
                      borderRadius: "10px",
                      textTransform: "none",
                      fontWeight: 700,
                      color: "#fff",
                      bgcolor: "#5f8e20",

                      "&:hover": {
                        bgcolor: "#4f7819",
                      },
                    }}
                  >
                    Approve
                  </Button>

                  <Button
                    onClick={() =>
                      openStatusDialog(request, "rejected")
                    }
                    disabled={loading}
                    startIcon={<XCircle size={15} />}
                    sx={{
                      borderRadius: "10px",
                      textTransform: "none",
                      fontWeight: 700,
                      color: "#e0655f",
                      bgcolor: "rgba(224,101,95,.07)",
                      border: "1px solid rgba(224,101,95,.25)",

                      "&:hover": {
                        bgcolor: "rgba(224,101,95,.13)",
                      },
                    }}
                  >
                    Reject
                  </Button>

                  <Button
                    onClick={() =>
                      openStatusDialog(request, "pending")
                    }
                    disabled={loading}
                    startIcon={<Clock size={15} />}
                    sx={{
                      borderRadius: "10px",
                      textTransform: "none",
                      fontWeight: 700,
                      color: GOLD2,
                      bgcolor: goldA(0.06),
                      border: `1px solid ${goldA(0.25)}`,

                      "&:hover": {
                        bgcolor: goldA(0.12),
                      },
                    }}
                  >
                    Pending
                  </Button>
                </Box>
              </Box>
            );
          })}
        </Box>
      )}


      <Dialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        fullWidth
        maxWidth="sm"
        PaperProps={{
          sx: {
            borderRadius: "18px",
            bgcolor: SURFACE,
            border: `1px solid ${BORDER}`,
          },
        }}
      >
        <DialogTitle
          sx={{
            color: TEXT,
            fontWeight: 800,
          }}
        >
          Update Book Request
        </DialogTitle>

        <DialogContent>
          <Typography
            sx={{
              color: MUTED,
              fontSize: 13,
              mb: 2,
            }}
          >
            Change the request status and optionally add an admin note.
          </Typography>

          {selectedRequest && (
            <Box
              sx={{
                mb: 2,
                p: 1.5,
                borderRadius: "12px",
                bgcolor: goldA(0.05),
                border: `1px solid ${BORDER}`,
              }}
            >
              <Typography
                sx={{
                  fontSize: 13,
                  fontWeight: 700,
                  color: TEXT,
                }}
              >
                {selectedRequest.book_title}
              </Typography>

              <Typography
                sx={{
                  fontSize: 11.5,
                  color: MUTED,
                  mt: 0.3,
                }}
              >
                {selectedRequest.author_name}
              </Typography>
            </Box>
          )}

          <TextField
            fullWidth
            multiline
            rows={4}
            label="Admin Note"
            value={adminNote}
            onChange={(e) => setAdminNote(e.target.value)}
            placeholder="Write a note for the customer..."
            sx={{
              "& .MuiOutlinedInput-root": {
                borderRadius: "12px",
              },
            }}
          />
        </DialogContent>

        <DialogActions sx={{ p: 2 }}>
          <Button
            onClick={() => setDialogOpen(false)}
            sx={{
              textTransform: "none",
              color: MUTED,
            }}
          >
            Cancel
          </Button>

          <Button
            onClick={handleUpdateStatus}
            disabled={loading}
            variant="contained"
            sx={{
              textTransform: "none",
              fontWeight: 700,
              borderRadius: "10px",
              bgcolor: GOLD2,

              "&:hover": {
                bgcolor: GOLD,
              },
            }}
          >
            {loading ? (
              <CircularProgress
                size={20}
                sx={{
                  color: "#fff",
                }}
              />
            ) : (
              "Confirm Update"
            )}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}