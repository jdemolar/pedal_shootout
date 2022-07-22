import './index.scss';

interface Props {
	clnm: string;
	children?: React.ReactNode;
}

const FeatureTableColumnHeader = ({clnm, children}: Props) => {
	return <th className={'col-header-cell ' + clnm}>{children}</th>
}

export default FeatureTableColumnHeader;