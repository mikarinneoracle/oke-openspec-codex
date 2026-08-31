import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Container,
  CssBaseline,
  Divider,
  Paper,
  ThemeProvider,
  Typography,
  createTheme,
  useMediaQuery,
} from '@mui/material';
import type { FilterType, Task } from './types';
import AddTaskDialog from './components/AddTaskDialog';
import TodoFilters from './components/TodoFilters';
import TodoFooter from './components/TodoFooter';
import TodoList from './components/TodoList';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#171717', dark: '#000000', light: '#3c3c3c', contrastText: '#fff' },
    background: { default: '#F5F5F5', paper: '#ffffff' },
    text: { primary: '#171717', secondary: '#5c5c5c' },
    divider: '#E0E0E0',
  },
  shape: { borderRadius: 16 },
  typography: { fontFamily: 'Roboto, sans-serif' },
  components: {
    MuiButton: {
      styleOverrides: { root: { textTransform: 'none' } },
      defaultProps: { disableRipple: true, disableElevation: true, variant: 'outlined' },
    },
    MuiPaper: { styleOverrides: { root: { borderRadius: 24 }, elevation1: { boxShadow: '0px 6px 12px rgba(0, 0, 0, 0.05)' } } },
    MuiChip: { styleOverrides: { root: { fontWeight: 500 } } },
  },
});

function TodoApp() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [filter, setFilter] = useState<FilterType>('all');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [error, setError] = useState<string>();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  const request = useCallback(async <T,>(path: string, init?: RequestInit): Promise<T> => {
    const response = await fetch(path, { ...init, headers: { 'content-type': 'application/json', ...init?.headers } });
    if (!response.ok) throw new Error('The Todo service is temporarily unavailable.');
    return response.status === 204 ? undefined as T : response.json() as Promise<T>;
  }, []);

  const loadTasks = useCallback(async () => {
    try {
      setError(undefined);
      setTasks(await request<Task[]>('/api/tasks'));
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : 'The Todo service is temporarily unavailable.');
    }
  }, [request]);

  // This effect synchronizes UI state with the external Todo API on first render.
  // oxlint-disable-next-line react/set-state-in-effect
  useEffect(() => { void loadTasks(); }, [loadTasks]);

  const addTask = async (title: string) => {
    try {
      const task = await request<Task>('/api/tasks', { method: 'POST', body: JSON.stringify({ title }) });
      setTasks((current) => [task, ...current]);
      setError(undefined);
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'The Todo service is temporarily unavailable.');
    }
  };

  const toggleTask = async (id: string) => {
    const current = tasks.find((task) => task.id === id);
    if (!current) return;
    try {
      const task = await request<Task>(`/api/tasks/${id}`, { method: 'PATCH', body: JSON.stringify({ completed: !current.completed }) });
      setTasks((all) => all.map((item) => item.id === id ? task : item));
      setError(undefined);
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'The Todo service is temporarily unavailable.');
    }
  };

  const deleteTask = async (id: string) => {
    try {
      await request<void>(`/api/tasks/${id}`, { method: 'DELETE' });
      setTasks((current) => current.filter((task) => task.id !== id));
      setError(undefined);
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'The Todo service is temporarily unavailable.');
    }
  };

  const clearCompleted = async () => {
    try {
      await Promise.all(tasks.filter((task) => task.completed).map((task) => request<void>(`/api/tasks/${task.id}`, { method: 'DELETE' })));
      setTasks((current) => current.filter((task) => !task.completed));
      setError(undefined);
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'The Todo service is temporarily unavailable.');
    }
  };
  const counts = useMemo(() => ({
    all: tasks.length,
    active: tasks.filter((task) => !task.completed).length,
    completed: tasks.filter((task) => task.completed).length,
  }), [tasks]);
  const visibleTasks = useMemo(() => {
    if (filter === 'active') return tasks.filter((task) => !task.completed);
    if (filter === 'completed') return tasks.filter((task) => task.completed);
    return tasks;
  }, [tasks, filter]);

  return (
    <>
      <Box sx={{ bgcolor: 'background.default', minHeight: '100vh', py: { xs: 3, sm: 4 }, display: 'flex', alignItems: 'center' }}>
        <Container maxWidth="sm" sx={{ px: { xs: 2, sm: 3 } }}>
          <Paper sx={{ border: 1, borderColor: 'divider', overflow: 'hidden' }}>
            <Box sx={{ p: isMobile ? 2 : 3, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Typography variant="h5" component="h1">To-do list</Typography>
              <Button onClick={() => setDialogOpen(true)} size={isMobile ? 'small' : 'medium'}>Add new task</Button>
            </Box>
            <Divider />
            {error && <Alert severity="error" sx={{ mx: isMobile ? 2 : 3, mt: 2 }} onClose={() => setError(undefined)}>{error}</Alert>}
            <Box sx={{ px: isMobile ? 2 : 3, py: 1.5 }}><TodoFilters current={filter} counts={counts} onChange={setFilter} /></Box>
            <Divider />
            <Box sx={{ px: isMobile ? 1 : 2, py: 0.5, height: '40vh', overflowY: 'auto', display: 'flex', flexDirection: 'column' }}>
              <TodoList tasks={visibleTasks} filter={filter} onToggle={(id) => void toggleTask(id)} onDelete={(id) => void deleteTask(id)} />
            </Box>
            <Divider />
            <Box sx={{ px: isMobile ? 2 : 3, py: 1.5 }}><TodoFooter activeCount={counts.active} completedCount={counts.completed} onClearCompleted={() => void clearCompleted()} /></Box>
          </Paper>
        </Container>
      </Box>
      <AddTaskDialog open={dialogOpen} onAdd={(title) => void addTask(title)} onClose={() => setDialogOpen(false)} />
    </>
  );
}

export default function App() {
  return <ThemeProvider theme={theme}><CssBaseline /><TodoApp /></ThemeProvider>;
}
