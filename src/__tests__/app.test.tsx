import { render } from '@testing-library/react';

import App from '../components/App';

test('renders app component', () => {
	const { container, getByRole } = render(<App />);

	expect(getByRole('main')).toBeInTheDocument();
	expect(container).toMatchSnapshot();
});