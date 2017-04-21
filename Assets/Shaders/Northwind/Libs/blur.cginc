float4 BlurProj(sampler2D image, float4 uv, int iterations, float blurAmount) {
	float4 color = tex2Dproj(image, uv);

	for (int x = -iterations; x < iterations; x++) {
		for (int y = -iterations; y < iterations; y++) {
			float2 way = float2(x / _ScreenParams.x, y / _ScreenParams.y) * (blurAmount);
			float dist = length(way);

			float width = 1 / iterations;

			float strength = (-pow(dist * width, 2) + 1)*max(0, (-pow(dist * width, 2) + 1));

			color += tex2Dproj(image, uv + float4(way.xy, 0, 0)) * strength;
		}
	}
	color /= (iterations * 2 + 1) * (iterations * 2 + 1);
	return color;
}

float4 Blur(sampler2D image, float2 uv, int iterations, float blurAmount, float2 imageSize) {
	float4 color = tex2D(image, uv);

	for (int x = -iterations; x < iterations; x++) {
		for (int y = -iterations; y < iterations; y++) {
			float2 way = float2(x / imageSize.x, y / imageSize.y) * (blurAmount);
			float dist = length(way);

			float width = 1 / iterations;

			float strength = (-pow(dist * width, 2) + 1)*max(0, (-pow(dist * width, 2) + 1));

			color += tex2D(image, uv + float2(way.xy)) * strength;
		}
	}
	color /= (iterations * 2 + 1) * (iterations * 2 + 1);
	return color;
}