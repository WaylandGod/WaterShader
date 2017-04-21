using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Northwind.Shaders.InteractiveWater
{
    public class WaterShock : MonoBehaviour
    {

        private Collider _collider;

        void Start()
        {
            _collider = GetComponent<Collider>();
            Shader.SetGlobalVector("_WaterShockPosition", new Vector4(0f, 0f, 0f, float.MaxValue));
        }

        void OnMouseDown()
        {
            if (this.enabled)
            {
                Ray lRay = Camera.main.ScreenPointToRay(Input.mousePosition);
                RaycastHit lHit;

                if (_collider.Raycast(lRay, out lHit, float.MaxValue))
                {
                    Vector3 lHitPos = lHit.point;
                    Shader.SetGlobalVector("_WaterShockPosition", new Vector4(lHitPos.x, lHitPos.y, lHitPos.z, Time.time));
                }
            }
        }
    }
}