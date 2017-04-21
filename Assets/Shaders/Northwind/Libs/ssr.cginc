float4x4 inverseM(float4x4 input)
{
#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
	//determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))

	float4x4 cofactors = float4x4(
		minor(_22_23_24, _32_33_34, _42_43_44),
		-minor(_21_23_24, _31_33_34, _41_43_44),
		minor(_21_22_24, _31_32_34, _41_42_44),
		-minor(_21_22_23, _31_32_33, _41_42_43),

		-minor(_12_13_14, _32_33_34, _42_43_44),
		minor(_11_13_14, _31_33_34, _41_43_44),
		-minor(_11_12_14, _31_32_34, _41_42_44),
		minor(_11_12_13, _31_32_33, _41_42_43),

		minor(_12_13_14, _22_23_24, _42_43_44),
		-minor(_11_13_14, _21_23_24, _41_43_44),
		minor(_11_12_14, _21_22_24, _41_42_44),
		-minor(_11_12_13, _21_22_23, _41_42_43),

		-minor(_12_13_14, _22_23_24, _32_33_34),
		minor(_11_13_14, _21_23_24, _31_33_34),
		-minor(_11_12_14, _21_22_24, _31_32_34),
		minor(_11_12_13, _21_22_23, _31_32_33)
		);
#undef minor
	return transpose(cofactors) / determinant(input);
}

float3 VSPositionFromDepth(float2 vTexCoord, sampler2D depth)
{
	// Get the depth value for this pixel
	float z = tex2D(depth, vTexCoord);
	// Get x/w and y/w from the viewport position
	float x = vTexCoord.x * 2 - 1;
	float y = (1 - vTexCoord.y) * 2 - 1;
	float4 vProjectedPos = float4(x, y, z, 1);
	// Transform by the inverse projection matrix
	float4 vPositionVS = mul(inverseM(UNITY_MATRIX_P), vProjectedPos);
	// Divide by w to get the view-space position
	return vPositionVS.xyz / vPositionVS.w;
}

float3 WSPositionFromVS(float3 viewSpaceCoordinates)
{
	float4 VSCoord = float4(viewSpaceCoordinates.xyz, 1);
	float4 vPositionWS = mul(inverseM(UNITY_MATRIX_V), VSCoord);
	// Divide by w to get the view-space position
	return vPositionWS.xyz / vPositionWS.w;
}

float4 SSR(sampler2D cameraImage, sampler2D zBuffer, float3 worldPos, float3 worldNormal, float3 ray, float iterations, float stepSize, float fadeSteps, float fadeDistance, bool debugDistance) {

	//World Position
	float4 lWorldPos = float4(worldPos.xyz, 1);
	float4 lInternalWorldPos = lWorldPos;
	//Clip Position
	float4 lInternalClipPos = mul(UNITY_MATRIX_VP, lWorldPos);
	lInternalClipPos /= lInternalClipPos.w;
	//API Clip Position
	lInternalClipPos.xy = (float2(lInternalClipPos.x, -lInternalClipPos.y) + 1) / 2;
	lInternalClipPos.z = distance(_WorldSpaceCameraPos.xyz, lWorldPos.xyz) - _ProjectionParams.y;


	//World Reflection
	float4 lWorldRef = float4(normalize(ray.xyz), 1);
	//Clip Reflection
	float4 lClipRef = mul(UNITY_MATRIX_VP, lWorldRef);
	lClipRef /= lClipRef.w;
	//API Clip Reflection
	lClipRef.xy = (float2(lClipRef.x, -lClipRef.y) + 1) / 2;

	float4 color = float4(0, 0, 0, 0);

	bool closed = false;

	float step = 0;
	while (step < iterations) {
		step++;

		//fading
		float fade = 1 - saturate((step - iterations + fadeSteps) / fadeSteps);// 1 - (step / iterations);
		fade *= 1 - saturate(distance(worldPos, lWorldPos.xyz) / fadeDistance);

		//Marsh Ray
		lWorldPos.xyz += lWorldRef.xyz * stepSize;

		//Clip Position
		float4 lClipPos = mul(UNITY_MATRIX_VP, lWorldPos);
		lClipPos /= lClipPos.w;
		//API Clip Position
		lClipPos.xy = (float2(lClipPos.x, lClipPos.y * _ProjectionParams.x) + 1) / 2;
		lClipPos.z = distance(_WorldSpaceCameraPos.xyz, lWorldPos.xyz) - _ProjectionParams.y;

		float fadeDist = distance(lClipPos.xy, float2(0.5, 0.5)) * 2;
		fade *= saturate(1 - fadeDist * fadeDist);

		//Depth Buffer Value
		float lDepth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(zBuffer, lClipPos.xy)));

		if ((lClipPos.x > 1 || lClipPos.x < 0 || lClipPos.y > 1 || lClipPos.y < 0) && !closed) {
			color = float4(0, 0, 0, 0);
			closed = true;
		}

		//Screen To World Pos
		float3 viewPos = VSPositionFromDepth(lClipPos.xy, zBuffer);
		float3 lStepWorldPos = WSPositionFromVS(viewPos);

		float3 lDir = normalize(lStepWorldPos - worldPos);
		float lAngle = dot(worldNormal, lDir);

		if (lAngle > 0 && distance(lStepWorldPos.xyz, lWorldPos.xyz) < stepSize && !closed) {
			color = tex2D(cameraImage, lClipPos.xy) * fade;
			if (debugDistance) {
				color = float4(step.xxx / iterations, 1) * 2;
			}
			closed = true;
		}
		else if (!closed) {
			color = float4(0, 0, 0, 0);
			if (debugDistance) {
				float4(step.xxx / iterations, 1) * 2;
			}
		}
	}

	return color;
}