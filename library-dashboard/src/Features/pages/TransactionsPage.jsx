import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { 
  Box, Typography, Chip, CircularProgress, Paper, Table, TableBody, TableCell, 
  TableContainer, TableHead, TableRow, Button, Dialog, DialogTitle, 
  DialogContent, TextField, DialogActions, MenuItem
} from "@mui/material";
import { getAllTransactions, checkoutTransaction } from "../../Core/Redux/Thunks/TranscationThunk"; 
import toast from 'react-hot-toast'; 
export default function TransactionsPage() {
  const dispatch = useDispatch();
  const { transactions, loading } = useSelector((state) => state.Transcation);
  
const getStatusColor = (status) => {
  switch (status) {
    case 'received':
      return { bg: 'rgba(74, 222, 128, 0.1)', text: '#4ade80' }; 
    case 'sold':
      return { bg: 'rgba(201, 168, 76, 0.1)', text: '#c9a84c' };
    case 'returned':
      return { bg: 'rgba(59, 130, 246, 0.1)', text: '#3b82f6' };
    default:
      return { bg: 'rgba(255, 255, 255, 0.1)', text: '#fff' };   
  }
};  const [open, setOpen] = useState(false);
  const [formData, setFormData] = useState({
    bill_id: '',
    book_id: '',
    type: 'borrow',
    days: 7,
    payment_method: 'cash'
  });

  useEffect(() => {
    dispatch(getAllTransactions());
  }, [dispatch]);
const handleCheckout = async () => {
  const payload = {
    bill_id: parseInt(formData.bill_id),
    items: [
      {
        book_id: parseInt(formData.book_id),
        action_type: formData.type, 
        days: parseInt(formData.days),
        payment_method: formData.payment_method
      }
    ]
  };

  try {
    await dispatch(checkoutTransaction(payload)).unwrap();
toast.success("Added Successfull!");
    setOpen(false);
    dispatch(getAllTransactions());
  } catch (err) {
    console.error("تفاصيل الخطأ:", err);
    const errorMsg = err?.errors?.['items.0.action_type']?.[0] || "حدث خطأ أثناء الإرسال";
toast.error(errorMsg);
  }
};
  return (
    <Box sx={{ minHeight: "100vh", bgcolor: "#0a0a0f", p: 3, color: "#fff" }}>
      <Box sx={{ mb: 4, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <Typography sx={{ fontSize: 28, fontWeight: 800 }}>All Transactions</Typography>
        <Button onClick={() => setOpen(true)} sx={{ bgcolor: "#c9a84c", color: "#000", fontWeight: 700 }}>
          New Checkout
        </Button>
      </Box>

      <Dialog open={open} onClose={() => setOpen(false)} PaperProps={{ sx: { bgcolor: "#111118", color: "#fff", width: '400px' } }}>
        <DialogTitle>New Transaction</DialogTitle>
        <DialogContent>
          <TextField fullWidth label="Bill ID" margin="dense" variant="filled" sx={{ input: { color: '#fff' } }} onChange={(e) => setFormData({...formData, bill_id: e.target.value})} />
          <TextField fullWidth label="Book ID" margin="dense" variant="filled" sx={{ input: { color: '#fff' } }} onChange={(e) => setFormData({...formData, book_id: e.target.value})} />
          <TextField select fullWidth label="Type" margin="dense" variant="filled" value={formData.type} onChange={(e) => setFormData({...formData, type: e.target.value})}>
            <MenuItem value="borrow">Borrow</MenuItem>
            <MenuItem value="buy">Buy</MenuItem>
          </TextField>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpen(false)} sx={{ color: '#aaa' }}>Cancel</Button>
          <Button onClick={handleCheckout} sx={{ color: '#c9a84c' }}>Confirm</Button>
        </DialogActions>
      </Dialog>

      <TableContainer component={Paper} sx={{ bgcolor: "#111118", borderRadius: "20px", border: "1px solid rgba(255,255,255,0.06)" }}>
        {loading ? <Box sx={{color:"#c9a84c", p: 5, textAlign: 'center' }}><CircularProgress /></Box> : (
          <Table>
            <TableHead sx={{ bgcolor: "rgba(255,255,255,0.02)" }}>
              <TableRow>
                {["ID", "User", "Price", "Type", "Status", "Date"].map(h => <TableCell key={h} sx={{ color: "rgba(255,255,255,0.4)", border: "none" }}>{h}</TableCell>)}
              </TableRow>
            </TableHead>
            <TableBody>
              {transactions?.map((row) => (
                <TableRow key={row.id}>
                  <TableCell sx={{ color: "#fff", border: "none" }}>#{row.bill_id}</TableCell>
                  <TableCell sx={{ color: "#fff", border: "none" }}>User {row.user_id}</TableCell>
                  <TableCell sx={{ color: "#c9a84c", border: "none" }}>{row.price} SYP</TableCell>
                  <TableCell sx={{ color: "#fff", border: "none" }}>{row.type}</TableCell>
<TableCell sx={{ border: "none" }}>
  <Chip 
    label={row.status} 
    size="small" 
    sx={{ 
      fontWeight: 600,
      fontSize: 10,
      bgcolor: getStatusColor(row.status).bg,
      color: getStatusColor(row.status).text,
      border: `1px solid ${getStatusColor(row.status).text}`,
    }} 
  />
</TableCell>                  <TableCell sx={{ color: "#aaa", border: "none" }}>{new Date(row.created_at).toLocaleDateString()}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </TableContainer>
    </Box>
  );
}