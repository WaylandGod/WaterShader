using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Northwind.Shaders.InteractiveWater
{
    public class WaterDeformer : MonoBehaviour
    {

        private Collider _collider;

        private float _timer = 0f;

        void Start()
        {
            _collider = GetComponent<Collider>();
        }

        private void Update()
        {
            _timer -= Time.deltaTime;
        }

        void OnMouseDrag()
        {
            if (this.enabled)
            {
                Ray lRay = Camera.main.ScreenPointToRay(Input.mousePosition);
                RaycastHit lHit;

                if (_timer <= 0f && _collider.Raycast(lRay, out lHit, float.MaxValue))
                {
                    _timer = 0.1f;

                    Vector3 lHitPos = lHit.point;
                    WaterDeformerController.main.AddRipplePoint(lHitPos);
                }
            }
        }
    }
}