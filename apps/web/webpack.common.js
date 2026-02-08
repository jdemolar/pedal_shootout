const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const NodePolyfillPlugin = require('node-polyfill-webpack-plugin');

module.exports = {
	entry: './src/index.tsx',
	plugins: [
		new HtmlWebpackPlugin({
			template: 'src/index.html',
		}),
		new CopyPlugin({
			patterns: [{ from: 'src/icons' }],
		}),
		new NodePolyfillPlugin()
	],
	module: {
		rules: [
			{
				test: /\.tsx?$/,
				use: 'ts-loader',
				exclude: /node_modules/,
			},
			{
				test: /\.jsx$/,
				use: {
					loader: 'babel-loader',
					options: {
						presets: [['@babel/preset-react', { runtime: 'automatic' }]],
					},
				},
				exclude: /node_modules/,
			},
			{
				test: /\.(scss|sass|css)$/,
				use: ['style-loader', 'css-loader', 'sass-loader'],
			},
			{
				test: /\.(png|svg|jpg|jpeg|gif|ico)$/i,
				type: 'asset/resource',
			},
			{
				test: /\.(woff|woff2|eot|ttf|otf)$/i,
				type: 'asset/resource',
			},
		],
	},
	resolve: {
		extensions: ['.tsx', '.ts', '.js', '.jsx', '.json'],
	},
	output: {
		filename: 'bundle.js',
		path: path.resolve(__dirname, 'build'),
		clean: true,
	},
};