import { useState, useEffect } from 'react';

interface UseApiDataResult<T> {
  data: T[];
  loading: boolean;
  error: string | null;
}

export function useApiData<TRaw, TDisplay>(
  fetchFn: () => Promise<TRaw[]>,
  transformFn: (raw: TRaw) => TDisplay,
): UseApiDataResult<TDisplay> {
  const [data, setData] = useState<TDisplay[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    fetchFn()
      .then(raw => {
        if (!cancelled) {
          setData(raw.map(transformFn));
          setLoading(false);
        }
      })
      .catch(err => {
        if (!cancelled) {
          setError(err.message);
          setLoading(false);
        }
      });
    return () => { cancelled = true; };
  }, []);

  return { data, loading, error };
}
