import { useEffect, useState } from "react";
import { useParams, useLocation } from "react-router-dom";
import { useDispatch, useSelector } from "react-redux";
import { Box, Typography, Chip, CircularProgress, Button } from "@mui/material";
import { motion } from "framer-motion";
import {
  BookOpen, User, Phone, MapPin, 
  FileText, MessageSquare, CheckCircle2, Clock, XCircle,
} from "lucide-react";

import { updateBookRequestStatus } from "../../Core/Redux/Thunks/BookRequestThunk";
import { clearBookRequestState } from "../../Core/Redux/Slice/BookRequestSlice";
import { GOLD, GOLD_DEEP as GOLD2, INK as TEXT, PAGE_BG as BG, CARD_BG as SURFACE, CARD_BG_HOVER, inkA, goldA } from "../../Core/Constants/ColorsUse";

const BORDER = goldA(0.15);
const MUTED  = inkA(0.5);


const STATUS_META = {
  approved: { label: "Approved", color: "#3fb873", bg: "rgba(63,184,115,0.1)",  border: "rgba(63,184,115,0.24)",  icon: <CheckCircle2 size={13} /> },
  pending:  { label: "Pending",  color: GOLD2,      bg: "rgba(201,168,76,0.1)",  border: "rgba(201,168,76,0.24)",  icon: <Clock size={13} /> },
  rejected: { label: "Rejected", color: "#e0655f",  bg: "rgba(224,101,95,0.1)", border: "rgba(224,101,95,0.24)", icon: <XCircle size={13} /> },
};

function StatusChip({ status }) {
  const meta = STATUS_META[status] || STATUS_META.pending;
  return (
    <Box sx={{
      display: "inline-flex", alignItems: "center", gap: "6px",
      px: "12px", py: "5px", borderRadius: "20px",
      fontSize: 12, fontWeight: 700, letterSpacing: 0.3,
      bgcolor: meta.bg, border: `1px solid ${meta.border}`, color: meta.color,
    }}>
      {meta.icon} {meta.label}
    </Box>
  );
}

function InfoCard({ icon, iconBg, iconColor, title, children, sx = {} }) {
  return (
    <Box
      component={motion.div}
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      sx={{
        p: "20px", borderRadius: "18px",
        bgcolor: SURFACE, border: `1px solid ${BORDER}`,
        boxShadow: "0 2px 14px rgba(201,168,76,.08)",
        transition: "all 0.25s",
        "&:hover": { borderColor: `${iconColor}40`, transform: "translateY(-2px)", bgcolor: CARD_BG_HOVER },
        ...sx,
      }}
    >
      <Box sx={{ display: "flex", alignItems: "center", gap: 1.2, mb: 2 }}>
        <Box sx={{ width: 28, height: 28, borderRadius: "8px", bgcolor: iconBg, color: iconColor, display: "flex", alignItems: "center", justifyContent: "center" }}>
          {icon}
        </Box>
        <Typography sx={{ fontSize: 13, fontWeight: 700, color: inkA(0.55), letterSpacing: 0.3 }}>
          {title}
        </Typography>
      </Box>
      {children}
    </Box>
  );
}

function Row({ label, value }) {
  return (
    <Box sx={{ display: "flex", justifyContent: "space-between", py: 0.8, borderBottom: `1px solid ${BORDER}`, gap: 2 }}>
      <Typography sx={{ fontSize: 12, color: MUTED, fontWeight: 600, whiteSpace: "nowrap" }}>{label}</Typography>
      <Typography sx={{ fontSize: 12.5, color: TEXT, fontWeight: 600, textAlign: "right", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
        {value ?? "—"}
      </Typography>
    </Box>
  );
}

const formatDate = (iso) => {
  if (!iso) return "—";
  return new Date(iso).toLocaleDateString("en-GB", { year: "numeric", month: "short", day: "numeric" });
};
export default function BookRequestDetailsPage() {
  const { id } = useParams();
  const location = useLocation();
  const dispatch = useDispatch();

  const { updatedRequest, loading, error, successMessage } = useSelector((state) => state.BookRequest) || {};
console.log( `state: ${updatedRequest}`);
  const initialRequest = location.state?.request || null;
  const [request, setRequest] = useState(initialRequest);
console.log(initialRequest);
  useEffect(() => {
    if (updatedRequest?.data) {
      setRequest(updatedRequest.data);
    }
  }, [updatedRequest]);

  const customer = request?.customer;

  useEffect(() => {
    return () => { dispatch(clearBookRequestState()); };
  }, [dispatch]);

  const handleStatusChange = (status, admin_note = "") => {
    dispatch(updateBookRequestStatus({ requestId: request?.id ?? id, status, admin_note }));
  };

  if (!request) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: BG, display: "flex", alignItems: "center", justifyContent: "center", p: 3, textAlign: "center" }}>
        <Typography sx={{ color: MUTED, fontSize: 13 }}>
          No book request data found. Open this page from the requests list.
        </Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: BG, p: { xs: 2, md: "20px 24px" }, fontFamily: "Inter, sans-serif" }}>

      <Box
        sx={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          mb: 3, px: "20px", height: 60,
          bgcolor: "rgba(255,255,255,.75)",
          border: `1px solid ${BORDER}`,
          borderRadius: "16px",
          position: "sticky", top: 0, zIndex: 10,
          backdropFilter: "blur(16px)",
          boxShadow: "0 2px 16px rgba(201,168,76,.08)",
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
            <BookOpen size={17} color="#fff" />
          </Box>
          <Typography sx={{ fontWeight: 700, fontSize: 15, color: TEXT, letterSpacing: -0.3 }}>
            Book Request #{request.id}
          </Typography>
        </Box>

        <StatusChip status={request.status} />
      </Box>

      <Box
        sx={{
          p: { xs: 3, md: "36px 40px" },
          borderRadius: "20px",
          background: `linear-gradient(135deg,${SURFACE} 0%,${CARD_BG_HOVER} 100%)`,
          border: `1px solid ${goldA(0.22)}`,
          position: "relative", overflow: "hidden",
          mb: 2.5,
          boxShadow: "0 4px 20px rgba(201,168,76,.1)",
        }}
      >
        <Box sx={{ position: "absolute", top: -100, right: -80, width: 300, height: 300, background: "radial-gradient(circle,rgba(201,168,76,0.16) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: -60, left: -40, width: 200, height: 200, background: "radial-gradient(circle,rgba(139,94,26,0.1) 0%,transparent 70%)", pointerEvents: "none" }} />
        <Box sx={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 1, background: "linear-gradient(90deg,transparent,rgba(201,168,76,0.4),transparent)" }} />

        <Chip
          label="● Book Request"
          size="small"
          sx={{
            mb: 2.5,
            bgcolor: goldA(0.1),
            border: `1px solid ${goldA(0.24)}`,
            color: GOLD2, fontWeight: 600, fontSize: 11,
            letterSpacing: 0.5, height: 24, borderRadius: "20px",
            "& .MuiChip-label": { px: 1.5 },
          }}
        />

        <Typography
          sx={{
            fontSize: { xs: 22, md: 30 }, fontWeight: 800,
            letterSpacing: -1, lineHeight: 1.2, mb: 1.5,
            background: `linear-gradient(135deg,${TEXT} 0%,${GOLD2} 100%)`,
            WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent", backgroundClip: "text",
          }}
        >
          {request.book_title}
        </Typography>

        <Typography sx={{ fontSize: 14, color: inkA(0.55), lineHeight: 1.7, maxWidth: 460 }}>
          by {request.author_name}
        </Typography>

        {successMessage && (
          <Typography sx={{ mt: 2, fontSize: 12.5, color: "#2f9b62", display: "flex", alignItems: "center", gap: 0.6 }}>
            <CheckCircle2 size={13} /> {successMessage}
          </Typography>
        )}
        {error && (
          <Typography sx={{ mt: 2, fontSize: 12.5, color: "#e0655f", display: "flex", alignItems: "center", gap: 0.6 }}>
            <XCircle size={13} /> {error?.message || "Something went wrong"}
          </Typography>
        )}
      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", md: "1fr 1fr" }, gap: 2, mb: 2 }}>

        <InfoCard
          icon={<FileText size={15} />}
          iconBg={goldA(0.16)}
          iconColor={GOLD2}
          title="Request Details"
        >
          <Box sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}>
            <Row label="Book Title" value={request.book_title} />
            <Row label="Author" value={request.author_name} />
            <Row label="Status" value={STATUS_META[request.status]?.label || request.status} />
            <Row label="Created" value={formatDate(request.created_at)} />
            <Row label="Updated" value={formatDate(request.updated_at)} />
          </Box>
        </InfoCard>

        <InfoCard
          icon={<User size={15} />}
          iconBg="rgba(127,119,221,0.16)"
          iconColor="#6a61d1"
          title="Customer"
        >
          <Box sx={{ display: "flex", alignItems: "center", gap: 1.5, mb: 2 }}>
            <Box
              sx={{
                width: 40, height: 40, borderRadius: "12px",
                background: "linear-gradient(135deg,#7f77dd,#4a43a0)",
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 14, fontWeight: 700, color: "#fff", flexShrink: 0,
              }}
            >
              {customer?.name?.split(" ").slice(0, 2).map((w) => w[0]?.toUpperCase()).join("")}
            </Box>
            <Box sx={{ minWidth: 0 }}>
              <Typography sx={{ fontSize: 13.5, fontWeight: 700, color: TEXT, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                {customer?.name}
              </Typography>
              <Typography sx={{ fontSize: 11.5, color: MUTED, display: "flex", alignItems: "center", gap: 0.5, mt: 0.2 }}>
                <Phone size={11} /> {customer?.phone}
              </Typography>
            </Box>
          </Box>

          <Box sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}>
            <Row label="Gender" value={customer?.gender === "F" ? "Female" : customer?.gender === "M" ? "Male" : customer?.gender} />
            <Row label="Date of Birth" value={formatDate(customer?.DOB)} />
            <Row label="Points Balance" value={customer?.points_balance} />
            <Row label="Borrow Limit" value={customer?.max_borrowing_limit} />
            <Box sx={{ display: "flex", justifyContent: "space-between", py: 0.8, gap: 2, alignItems: "flex-start" }}>
              <Typography sx={{ fontSize: 12, color: MUTED, fontWeight: 600, display: "flex", alignItems: "center", gap: 0.5, whiteSpace: "nowrap" }}>
                <MapPin size={12} /> Address
              </Typography>
              <Typography sx={{ fontSize: 12, color: TEXT, fontWeight: 500, textAlign: "right", whiteSpace: "pre-line" }}>
                {customer?.address}
              </Typography>
            </Box>
          </Box>
        </InfoCard>

      </Box>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", md: "1fr 1fr" }, gap: 2, mb: 2 }}>
        <InfoCard
          icon={<MessageSquare size={15} />}
          iconBg={goldA(0.08)}
          iconColor={inkA(0.55)}
          title="Customer Note"
        >
          <Typography sx={{ fontSize: 13, color: inkA(0.7), lineHeight: 1.7 }}>
            {request.notes || "No notes provided."}
          </Typography>
        </InfoCard>

        <InfoCard
          icon={<MessageSquare size={15} />}
          iconBg="rgba(151,196,89,0.16)"
          iconColor="#5f8e20"
          title="Admin Note"
        >
          <Typography sx={{ fontSize: 13, color: inkA(0.7), lineHeight: 1.7 }}>
            {request.admin_note || "No admin note yet."}
          </Typography>
        </InfoCard>
      </Box>

      <Box
        sx={{
          p: "20px", borderRadius: "18px",
          bgcolor: SURFACE, border: `1px solid ${BORDER}`,
          boxShadow: "0 2px 14px rgba(201,168,76,.08)",
          display: "flex", flexWrap: "wrap", alignItems: "center", justifyContent: "space-between", gap: 2,
        }}
      >
        <Box>
          <Typography sx={{ fontSize: 14, fontWeight: 700, color: TEXT, mb: 0.3 }}>
            Update request status
          </Typography>
          <Typography sx={{ fontSize: 12, color: MUTED }}>
            Changing the status notifies the customer automatically.
          </Typography>
        </Box>

        <Box sx={{ display: "flex", gap: 1.2 }}>
          <Button
            onClick={() => handleStatusChange("approved")}
            disabled={loading}
            startIcon={<CheckCircle2 size={15} />}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13,
              px: 2.5, color: "#fff",
              background: "linear-gradient(135deg,#97c459,#5f8e20)",
              "&:hover": { transform: "translateY(-1px)", boxShadow: "0 12px 28px rgba(151,196,89,0.25)" },
              "&:disabled": { opacity: 0.5, color: "#fff" },
              transition: "all 0.25s",
            }}
          >
            Approve
          </Button>

          <Button
            onClick={() => handleStatusChange("pending")}
            disabled={loading}
            startIcon={<Clock size={15} />}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13,
              px: 2.5, color: GOLD2,
              border: `1px solid ${goldA(0.32)}`,
              bgcolor: goldA(0.07),
              "&:hover": { bgcolor: goldA(0.13), borderColor: goldA(0.5) },
              "&:disabled": { opacity: 0.5 },
              transition: "all 0.25s",
            }}
          >
            Pending
          </Button>

          <Button
            onClick={() => handleStatusChange("rejected")}
            disabled={loading}
            startIcon={<XCircle size={15} />}
            sx={{
              borderRadius: "10px", textTransform: "none", fontWeight: 700, fontSize: 13,
              px: 2.5, color: "#e0655f",
              border: `1px solid rgba(224,101,95,0.32)`,
              bgcolor: "rgba(224,101,95,0.07)",
              "&:hover": { bgcolor: "rgba(224,101,95,0.13)", borderColor: "rgba(224,101,95,0.5)" },
              "&:disabled": { opacity: 0.5 },
              transition: "all 0.25s",
            }}
          >
            Reject
          </Button>

          {loading && <CircularProgress size={20} sx={{ color: GOLD, alignSelf: "center" }} />}
        </Box>
      </Box>
    </Box>
  );
}