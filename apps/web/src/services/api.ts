import {
  PedalApiResponse,
  ManufacturerApiResponse,
  MidiControllerApiResponse,
  PedalboardApiResponse,
  UtilityApiResponse,
} from '../types/api';

const API_BASE = process.env.REACT_APP_API_BASE_URL || 'http://localhost:8081';

async function get<T>(path: string): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`);
  if (!res.ok) {
    throw new Error(`GET ${path} failed: ${res.status}`);
  }
  return res.json();
}

export const api = {
  getPedals: () => get<PedalApiResponse[]>('/api/pedals'),
  getManufacturers: () => get<ManufacturerApiResponse[]>('/api/manufacturers'),
  getMidiControllers: () => get<MidiControllerApiResponse[]>('/api/midi-controllers'),
  getPedalboards: () => get<PedalboardApiResponse[]>('/api/pedalboards'),
  getUtilities: () => get<UtilityApiResponse[]>('/api/utilities'),
};
