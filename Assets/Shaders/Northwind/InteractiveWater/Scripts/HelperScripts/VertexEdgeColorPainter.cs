using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Northwind.Shaders.InteractiveWater
{
    public class VertexEdgeColorPainter : MonoBehaviour
    {

        Mesh _mesh;

        // Use this for initialization
        void Start()
        {
            _mesh = GetComponent<MeshFilter>().sharedMesh;
            Paint();
        }

        void Paint()
        {
            Color[] colors = new Color[_mesh.vertices.Length];
            int[] amount = new int[_mesh.vertices.Length];

            for (int t = 0; t < _mesh.triangles.Length; t++)
            {
                amount[_mesh.triangles[t]] += 1;
            }

            for (int v = 0; v < _mesh.vertices.Length; v++)
            {
                if (amount[v] <= 4)
                {
                    colors[v] = new Color(1f, 0f, 0f, 1f);
                }
                else
                {
                    colors[v] = new Color(0f, 0f, 0f, 1f);
                }
            }
            _mesh.colors = colors;
        }
    }
}