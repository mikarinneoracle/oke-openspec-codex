import { useState } from 'react';
import type { KeyboardEvent } from 'react';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, TextField } from '@mui/material';

interface AddTaskDialogProps {
  open: boolean;
  onAdd: (title: string) => void;
  onClose: () => void;
}

export default function AddTaskDialog({ open, onAdd, onClose }: AddTaskDialogProps) {
  const [value, setValue] = useState('');
  const handleClose = () => { setValue(''); onClose(); };
  const handleSubmit = () => { const trimmed = value.trim(); if (!trimmed) return; onAdd(trimmed); handleClose(); };
  const handleKeyDown = (event: KeyboardEvent<HTMLInputElement>) => { if (event.key === 'Enter') handleSubmit(); };
  return (
    <Dialog open={open} onClose={handleClose} fullWidth maxWidth="xs">
      <DialogTitle>Add task</DialogTitle>
      <DialogContent><TextField autoFocus fullWidth size="small" label="Task title" placeholder="What needs to be done?" value={value} onChange={(event) => setValue(event.target.value)} onKeyDown={handleKeyDown} sx={{ mt: 1 }} /></DialogContent>
      <DialogActions sx={{ px: 3, pb: 2 }}><Button variant="text" color="error" onClick={handleClose}>Cancel</Button><Button onClick={handleSubmit} disabled={!value.trim()}>Add</Button></DialogActions>
    </Dialog>
  );
}
