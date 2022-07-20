import './index.scss';

interface Props {
	clnm: string;
	children?: React.ReactNode;
}

const FeatureTableColumnHeader = ({clnm, children}: Props) => {
	return <th className={clnm}>{children}</th>
}

export default FeatureTableColumnHeader;