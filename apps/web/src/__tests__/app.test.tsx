import { render } from '@testing-library/react';

import App from '../components/App';

jest.mock('../hooks/useApiData', () => ({
	useApiData: () => ({ data: [], loading: false, error: null }),
}));

test('renders app component', () => {
	const { container, getByRole } = render(<App />);

	expect(getByRole('navigation')).toBeInTheDocument();
	expect(container).toMatchSnapshot();
});
