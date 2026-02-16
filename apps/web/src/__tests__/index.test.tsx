import ReactDOM from 'react-dom/client';
import App from '../components/App';

jest.mock('../hooks/useApiData', () => ({
	useApiData: () => ({ data: [], loading: false, error: null }),
}));

const rootMock = {
	render: jest.fn(),
};

jest.mock('react-dom/client', () => ({
	createRoot: jest.fn(() => rootMock),
}));

describe('Root DOM', () => {
	test('renders App', () => {
		const root = document.createElement('div');
		root.id = 'root';
		document.body.append(root);

		require('../index.tsx');

		expect(ReactDOM.createRoot).toHaveBeenCalledWith(root);
		expect(rootMock.render).toHaveBeenCalledWith(<App />);
	});
});