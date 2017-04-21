using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Northwind.Shaders.InteractiveWater
{
    public class WaterDeformerController : MonoBehaviour
    {

        public static WaterDeformerController main;

        private List<Vector4> _hits = new List<Vector4>();

        [Range(0, 50)]
        public int hitPoints = 20;

        public const int arrayLength = 50;

        void Awake()
        {
            main = this;
        }

        void Start()
        {
            _hits.Add(new Vector4(0f, 0f, 0f, -600f));
            Shader.SetGlobalVectorArray("_WaterRipplePositions", new Vector4[arrayLength]);
        }

        void SetShaderVariables()
        {
            Vector4[] lLastFive = new Vector4[arrayLength];

            for (int h = 0; h < Mathf.Min(arrayLength, _hits.Count); h++)
            {
                lLastFive[h] = _hits[_hits.Count - 1 - h];
            }

            Shader.SetGlobalVectorArray("_WaterRipplePositions", lLastFive);
            Shader.SetGlobalFloat("_WaterRippleCount", Mathf.Min(arrayLength, _hits.Count));
        }

        public void AddRipplePoint(Vector3 position, float time)
        {
            _hits.Add(new Vector4(position.x, position.y, position.z, time));
            RemoveLeft();
            SetShaderVariables();
        }

        public void AddRipplePoint(Vector3 position)
        {
            AddRipplePoint(position, Time.time);
        }

        public void RemoveLeft()
        {
            if (_hits.Count > hitPoints)
                _hits.RemoveAt(0);
            if (_hits.Count > hitPoints)
                RemoveLeft();
        }
    }
}